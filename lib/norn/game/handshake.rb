# encoding: US-ASCII
require "socket"
require "yaml"

module Norn
  ##
  ## @brief      Class for handshake with Simutronics service
  ##
  class Handshake < Struct.new(:account, :password, :game, :character)
    ##
    ## all control codes that can be sent to the auth service
    ##
    module CODES
      # accept key
      K = "K"
      # account info
      A = "A"
      # instance info
      M = "M"
      # detailed instance info
      N = "N"
      # send what instance to connect to
      F = "F"
      # gets game info
      G = "G"
      # pricing info?
      P = "P"
      # character info
      C = "C"
      # connect (link) to the game
      L = "L"
      # stormfront protocol
      STORM = "STORM"
    end
    ##
    ## @brief      Class for bad password.
    ##
    class BadPassword < Exception
    end
    ##
    ## @brief      Class for invalid game.
    ##
    class InvalidGame < Exception
      def initialize(game)
        super "invalid game: #{game}"
      end
    end
    ##
    ## @brief      class for generic response
    ##
    class Response < Struct.new(:code, :body)
      def self.parse(resp)
        code, *body = *resp[0..-1].split(/\s+/)
        new code, body
      end

      def is?(patt)
        body.join.match patt
      end

      def fetch(key)
        idx = values.index(key.to_s.upcase)
        idx ? self[idx + 1] : nil
      end

      def pairs(start=0, last=-1)
        Hash[*body[start..last]]
      end
    end
    ##
    ## @brief      Class for characters.
    ##
    class Characters < Struct.new(:number, :slots, :list)
    end
    ##
    ## @brief      Class for one-time password container
    ##
    class OTP < Struct.new(:upport, :game, :code, :name, :file, :host, :port, :key)
      def to_s
        ""
      end
    end
    ##
    ## authentication service constants
    ##
    HOST    = "eaccess.play.net"
    PORT    = 7900
    PORTALS = YAML.load_file File.join(File.dirname(__FILE__), "portals.yml")
    ##
    ## @brief      compute the hash of a password using SGE protocol
    ##             from: https://gswiki.play.net/SGE_protocol/saved_posts
    ##
    ## @param      password  The password
    ## @param      key       The key
    ##
    ## @return     ByteArray
    ##
    def self.compute(password, key)
      password.chars.zip(key)
        .map do |char, shift|
          ((char.getbyte(0)-32)^shift)+32
        end
    end

    def self.connect(port = Norn::Game::PORT, *args)
      new(*args) do |otp|
        Norn::Game.connect otp, port
      end
    end

    attr_accessor :socket, :key, :state, :otp, :responses, :characters
    
    def initialize(params, &block)
      super(*params.values_at(*self.class.members ))
      @socket    = TCPSocket.new(HOST, PORT)
      @responses = Array.new
      # tell the server we are ready for auth
      write CODES::K
      # pretty self explanatory
      if self.character
        fetch_key.authenticate.receive! :login
        yield @otp
      else
        fetch_key.authenticate.receive!(:character_list, &block)
      end
    end

    ##
    ## @brief      handles the incoming packets
    ##
    ## @return     self
    ##
    def receive!(mode=:login, &block)
      while !@socket.closed? && resp = @socket.gets
        handle_incoming(Response.parse(resp), mode, &block)
      end
      self
    end
    ##
    ## @brief      computes the hash for this handshake
    ##
    ## @return     String
    ##
    def hash
      Handshake.compute(password.dup.force_encoding(Encoding::ASCII), @key).map(&:chr).join
    end
    ##
    ## @brief      Fetches the hash key from the first-frame of the TCPSocket
    ##
    ## @return     self
    ##
    def fetch_key
      # work on the bytes
      @key = @socket.gets.force_encoding(Encoding::ASCII)
        .chars.map do |char| char.getbyte(0) end
      self
    end
    ##
    ## @brief      writes the computed authentication hash to the TCPSocket
    ##
    ## @return     self
    ##
    def authenticate
      write CODES::A, account, hash
      self
    end
    ##
    ## @brief      writes a tab delimited line to the TCPSocket
    ##
    ## @param      chunks  The chunks
    ##
    ## @return     self
    ##
    def write(*chunks)
      @state = chunks.first
      @socket.puts chunks.join("\t").concat("\n")
      self
    end
    ##
    ## @brief      kills the underlying TCPSocket to the auth service
    ##
    ## @return     self
    ##
    def die!
      @socket.close
      self
    end
    ##
    ## @brief      matches the packet received from the auth service
    ##             for processing
    ##
    ## @param      resp  The resp
    ##
    ## @return     void
    ##
    def handle_incoming(resp, mode, &block)
      @responses << resp
      case @state
      when CODES::A
        handle_auth_resp resp
      when CODES::M
        # make sure we have a valid game code
        raise InvalidGame.new(game) unless resp.body.include?(game)
        write CODES::F, game
      when CODES::F
        write CODES::G, game
      when CODES::G
        write CODES::P, game
      when CODES::P
        write CODES::C
      when CODES::C
        handle_character_list_resp(resp, mode, &block)
      when CODES::L
        handle_otp_resp resp
        die!
      else
        raise Exception.new "unexpected occurance in handshake: #{resp}"
      end
    end
    ##
    ## @brief      handles the response after a computed hash is sent
    ##             to authenticate with the service
    ##
    ## @param      resp  The resp
    ##
    ## @return     self
    ##
    def handle_auth_resp(resp)
      raise BadPassword.new if resp.is?(/^PASSWORD$/)
      write CODES::M
      self
    end
    ##
    ## @brief      handles the character list response from the auth
    ##             service
    ##
    ## @param      resp  The resp
    ##
    ## @return     self
    ##
    def handle_character_list_resp(resp, mode)
      @characters = Characters.new(resp.body[0], resp.body[1], Hash[*resp.body[4..-1]].invert)
      
      if mode == :character_list
        send_character_packet yield @characters, self
      else
        unless @characters.list[character.capitalize]
          raise Exception.new "character <#{character}> not found\n: #{@characters.list.keys.join(',')}"
        end

        send_character_packet @characters.list[character]
      end
      self
    end

    def send_character_packet(character)
      write CODES::L, character, CODES::STORM
      self
    end
    ##
    ## @brief      handles the one-time password response from the
    ##             auth service
    ##
    ## @param      resp  The resp
    ##
    ## @return     self
    ##
    def handle_otp_resp(resp)
      @otp = OTP.new *(resp.body[1..-1].map do |pair| 
        pair.split(/=/).pop 
      end)
      self
    end

    def finished?
      !@otp.nil?
    end

    def to_s
      "<Handshake>"
    end
  end
end
require "socket"
require "norn/game/handshake"
require "norn/util/worker"
require "norn/script/exec"

module Norn
  class Game < Struct.new(:handshake)
    ##
    ## self-contained packets that happen
    ## at the start of a session
    ##
    module PACKETS
      ALIVE         = /^<mode id="GAME"\/>$/
      AUTHENTICATED = /^<playerID id='(.*?)'\/>$/
      # prefix for Simu game commands
      COMMAND       = "<c>"
    end
    ##
    ## states that a Game instance can be in
    ##
    module STATES
      CONNECTING     = :CONNECTING
      AUTHENTICATING = :AUTHENTICATING
      CONNECTED      = :CONNECTED
      CLOSED         = :CLOSED
    end
    USER_AGENT  = "/FE:STORMFRONT /VERSION:1.0.1.22 /P:NORN@#{Norn::VERSION} /XML"
    PREFIX      =  "<c>"
    PORT        = 8383
    HOST        = "0.0.0.0"
    UPSTREAM    = :upstream
    DOWNSTREAM  = :downstream
    ##
    ## singleton instance, though must be reloadable
    ##
    @@instance  = nil
    ##
    ## @brief      returns the current game instance
    ##
    ## @return     Norn::Game
    ##
    def self.instance
      @@instance
    end
    ##
    ## @brief      kills the current game instance
    ##
    ## @return     self
    ##
    def self.die!
      instance.die!
      self
    end
    ##
    ## @brief      opens a downstream socket to the Game
    ##
    ## @return     TCPSocket
    ##
    def self.downstream
      TCPSocket.new(HOST, PORT)
    end
    ##
    ## @brief      kills and clears the current game instance
    ##
    ## @return     self
    ##
    def self.clear
      if @@instance
        @@instance.die!
      end
      @@instance = nil
      self
    end
    ##
    ## @brief      connects to a game instance
    ##
    ## @param      handshake  The handshake
    ##
    ## @return     self
    ##
    def self.connect(handshake, port = PORT)
      @@instance = new handshake, port
      self
    end

    attr_accessor :socket, :state, :callbacks, :threads, :clients
    ##
    ## @brief      initializes a Norn::Game instance
    ##
    ## @param      handshake  The handshake
    ## @param      port       The port to bind locally
    ##
    ## @return     self
    ##
    def initialize(handshake, port = PORT)
      super(handshake)
      @state      = STATES::CONNECTING
      @upstream   = TCPSocket.new(handshake.host, handshake.port.to_i)
      @downstream = TCPServer.open(port)
      @clients    = Array.new
      ##
      ## open our connection to the game
      ##
      Worker.new(:upstream) do
        while !@upstream.closed? && resp = @upstream.gets
          handle_incoming resp[0..-1]
        end
        die!
      end
      ##
      ## allow multiple FEs to connect
      ##
      Worker.new(:downstream) do
        until @downstream.closed?
          Thread.fork(@downstream.accept) do |client| 
            @clients << client
            while !client.closed? && cmd = client.gets
              if cmd.match(Norn::COMMAND)
                if cmd.match(Script::Exec::COMMAND)
                  Script::Exec.run(cmd)
                else
                  Script::UserScript.run(cmd)
                end
              else
                write_game_command(cmd)
              end
            end
            @clients.delete(client)
          end
        end
      end
    
    end
    ##
    ## @brief      Writes a game command.
    ##
    ## @param      str   The string
    ##
    ## @return     self
    ##
    def write_game_command(str)
      puts "command :: #{str}"
      write PACKETS::COMMAND, str
      self
    end
    ##
    ## write a command to all downstream clients
    ##
    def write_to_clients(str)
      @clients.each do |client|
        client.puts str.to_s.concat("\n")
      end
    end
    ##
    ## @brief      writes an array of strings to the game
    ##
    ## @param      chunks  The chunks
    ##
    ## @return     self
    ##
    def write(*chunks)
      chunks.each do |chunk|
        @upstream.puts chunk.concat("\n")
      end
      self
    end
    ##
    ## @brief      kills the game instance 
    ##             and notifies all listening clients
    ##
    ## @return     self
    ##
    def die!
      @clients.each do |client|
        # since any client may have killed the game connection
        # it is good UX to tell them that this has happened
        client.puts "*** connection closed ***"
        client.close
        @clients.delete(client)
      end
      @upstream.close
      @downstream.close
      self
    end
    ##
    ## @brief      handles an incoming game response
    ##             it forwards the raw response onto
    ##             clients that are attached (Profanity/Wizard/SF)
    ##             and also forwards a copy of the response to the Parser
    ##
    ## @param      resp  The resp
    ##
    ## @return     void
    ##
    def handle_incoming(resp)
      case resp
      when PACKETS::ALIVE
        @state = STATES::AUTHENTICATING
        # send the handshake from the authentication service
        # and our user agent string? doubt they actually
        # do anything with it, but it's in the spec
        write handshake.key, USER_AGENT
        handshake.key = :err
      when PACKETS::AUTHENTICATED
        @state = STATES::CONNECTED
        # weird version of ACK ¯\_(ツ)_/¯
        write PREFIX, PREFIX
      else
        
        # forward a copy of the response to the parser
        Parser << resp.dup
        # remove closed
        @clients = @clients.reject(&:closed?)
        # forward the response to each connected client
        @clients.each do |downstream| 
          downstream.puts resp unless downstream.closed?
        end
      end
    end

    def to_s
      %{<Norn::Game @state=#{@state}>}
    end
  end
end
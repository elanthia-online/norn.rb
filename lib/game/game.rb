require "socket"

module Norn
  class Game < Struct.new(:handshake)
    ##
    ## self-contained packets that happen
    ## at the start of a session
    ##
    module PACKETS
      ALIVE         = /^<mode id="GAME"\/>$/
      AUTHENTICATED = /^<playerID id='(.*?)'\/>$/
    end

    module STATES
      CONNECTING     = :CONNECTING
      AUTHENTICATING = :AUTHENTICATING
      CONNECTED      = :CONNECTED
      CLOSED         = :CLOSED
    end
    
    USER_AGENT  = "/FE:WIZARD /VERSION:1.0.1.22 /P:NORN@#{Norn::VERSION} /XML"
    PREFIX      =  "<c>"
    @@instance  = nil
    @@callbacks = Array.new

    def self.instance
      @@instance
    end

    def self.die!
      instance.die!
    end

    def self.callbacks
      @@callbacks
    end

    def self.on_connect(&block)
      @@callbacks.push(block)
      self
    end

    def self.clear
      @@callbacks.clear
      @@instance = nil
    end

    def self.connect(handshake)
      @@instance = new handshake
    end

    attr_accessor :socket, :state, :callbacks

    def initialize(handshake)
      super(handshake)
      @state     = STATES::CONNECTING
      @socket    = TCPSocket.new(handshake.host, handshake.port.to_i)
      
      while !@socket.closed? && resp = @socket.gets
        handle_incoming resp[0..-1]
      end
    end

    def write(*chunks)
      chunks.each do |chunk|
        @socket.puts chunk.concat("\n")
      end
      self
    end

    def die!
      @socket.close
      self
    end

    def handle_incoming(resp)
      case resp
      when PACKETS::ALIVE
        @state = STATES::AUTHENTICATING
        # send the handshake from the authentication service
        # and our user agent string? doubt they actually
        # do anything with it, but it's in the spec
        write handshake.key, USER_AGENT
      when PACKETS::AUTHENTICATED
        @state = STATES::CONNECTED
        # weird version of ACK ¯\_(ツ)_/¯
        write PREFIX, PREFIX
        # tell any callbacks
        Game.callbacks.each do |block|
          block.call(self)
        end
      else
        puts resp
        # TODO: write Norn::Parser
        # exit
      end
    end
  end
end
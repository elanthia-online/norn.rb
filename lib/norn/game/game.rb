require "socket"
require "norn/game/handshake"
require "norn/util/worker"
require "norn/util/thread-pool"
require "norn/script/exec"
require "norn/world/world"
require "norn/game/command"

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
    ## @brief      connects to a game instance
    ##
    ## @param      handshake  The handshake
    ##
    ## @return     self
    ##
    def self.connect(handshake, port = PORT)
      new(handshake, port)
    end
    ##
    ## attributes
    ##
    attr_accessor :socket, :upstream,
                  :callbacks, :threads, :state,
                  :clients, :parser, :world,
                  :scripts,
                  :port, :receivers, :mutators
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
      ## if we bound to 0 then we need to expose
      ## the real port we listened to
      @port       = @downstream.addr[1]
      ##
      ## create an isolated World instance
      ## to track state
      ##
      @world      = World.new
      ##
      ## clients (Wizard FE)
      ## they will receive a copy of 
      ## the mutated feed
      ##
      @clients    = Array.new
      ##
      ## asychronous callbacks that just receive
      ## a copy of the data from the feed
      ##
      @receivers  = Array.new
      ##
      ## callbacks that may mutate the Game feed
      ##
      @mutators   = Array.new
      ##
      ## registry for the scripts that are running
      ## in this game instance
      ##
      @scripts = ThreadPool.new
      ##
      ## open our connection to the game
      ##
      Worker.new(:upstream) do |worker|
        ##
        ## handle prelude
        ##
        until @upstream.closed? or @state.eql?(STATES::CONNECTED)
          handle_incoming @upstream.gets
          break if @state.eql?(STATES::CONNECTED)
        end
        ##
        ## create our Parser with a bridge to the World state
        ##
        @parser = Parser.new(@world.callbacks)
        ##
        ## handle parsing
        ##
        until @upstream.closed?
          packet = @upstream.gets
          if packet
            original_packet = packet.dup
            ## parser & receivers always receives raw game feed
            @parser.puts original_packet.dup
            ## receivers always 
            @receivers.each do |receiver|
              receiver.puts original_packet.dup
            end
            ## allow scripts to mutate the game feed
            mutated_packet = @mutators.reduce(original_packet) do |packet, mutator|
              result = mutator.call(packet)
              if result.eql?(:err)
                packet
              else
                result
              end
            end

            @clients.reject!(&:closed?)
            # forward the response to each connected client
            @clients.each do |downstream| 
              begin
                downstream.puts mutated_packet.dup unless downstream.closed?  
              rescue => exception
                System.log(exception, label: :game_error)
              end
            end
          end
        end
        ##
        ## cleanup
        ##
        @clients.each(&:close)
        @downstream.close
        worker.shutdown
      end
      ##
      ## allow multiple FEs to connect
      ##
      Worker.new(:downstream) do
        until @downstream.closed?
          Thread.fork(@downstream.accept) do |client| 
            @clients << client
            while !client.closed? && cmd = client.gets
              if Command.match?(cmd)
                Command.parse(self, cmd)
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
      write %{#{PACKETS::COMMAND}#{str}}
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
        unless @state == STATES::AUTHENTICATING
          raise Exception.new "unhandled Game<#{@state}>::PACKET<#{resp}>" 
        end
      end
    end
    ##
    ## create a downstream listener
    ##
    def listen()
      TCPSocket.new(HOST, @port)
    end
  end
end
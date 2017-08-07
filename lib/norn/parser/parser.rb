require "norn/util/worker"
require "norn/parser/decoder"
require "norn/dsl/tags"
Dir[File.dirname(__FILE__) + '/../world/**/*.rb'].each do |file| require file end

module Norn
  module Parser
    include Norn::DSL

    XML = %r{
      (<([a-zA-Z]+)[^>]*>.*?<\/\1>|<[^>]+>)
    }xm

    class ComponentDecoder
      include Decoder[
        open:  Parser::Tags::ComponentOpen,
        close: Parser::Tags::ComponentClose,
        cast: Proc.new do |contents, type, match|
          case type
          when :"room exits"
            [:noop, 
              Direction.parse(contents)]
          when :"room desc"
            [:noop,
              Room::Description.parse(contents)]
          when :"room players"
            [:noop,
              Players.parse(contents)]
          when :"room objs"
            [:noop,
              Room.put(:objs, 
                GameObj.parse(contents))]
          else
            ComponentDecoder.debug("possible data loss in component <#{type}>", type)
            [:noop,
              nil]
          end
        end
      ]
    end

    class StyleDecoder
      include Decoder[
        open: Parser::Tags::StyleOpen,
        close: Parser::Tags::StyleClose,
        content: Parser::Tags::StyleContent,
        cast: Proc.new do |contents, type, match|
          # StyleDecoder.debug contents, type
          case type
          when :roomDesc
            [:noop,
              Room::Description.parse(contents)]
          when :roomName
            [:noop, 
              Room.put(:title, contents)]
          else
            StyleDecoder.debug "potential data loss <#{type}>", type
            [:noop, 
              nil]
          end
        end
      ]
    end

    class StatusDecoder
      include Decoder[
        open: Parser::Tags::Status,
        cast: Proc.new do |status| 
          [:ok, 
            status.downcase == "y"]
        end
      ]
    end

    class StreamDecoder
      include Decoder[
        open:  Parser::Tags::StreamOpen,
        close: Parser::Tags::StreamClose,
        cast: Proc.new do |contents, type|
          case type
          when :speech
            [:noop, 
              contents]
          when :thoughts
            [:noop, 
              contents]
          # defer to inventory parser
          when :inv 
            [:noop,
              Inv.parse(contents)]
          when :bounty
            [:noop, 
              Bounty.parse(contents)]
          # defer to Component parser
          when :room
            [:noop, 
              ComponentDecoder.update(contents)]
          else
            StreamDecoder.debug("possible data loss in stream <#{type}>", type)
            [:noop, 
              contents]
          end
        end
      ]
    end

    class HandsDecoder
      include Decoder[
        open: Parser::Tags::HandOpen,
        close: Parser::Tags::HandClose,
        cast: Proc.new do |contents, type, match|
          [:noop, 
            Hand.new(type, match.id, match.noun, contents)]
        end
      ]
    end

    class RTDecoder
      include Decoder[
        open: Parser::Tags::RoundTime,
        cast: Proc.new do |contents, type, match|
          [:noop, 
            Roundtime.put(type, match.content)]
        end
      ]
    end

    class ServerOffsetDecoder
      include Decoder[
        open: Parser::Tags::Prompt,
        cast: Proc.new do |contents, type, match|
          [:noop,
            Roundtime.offset(match.content.to_i)]
        end
      ]
    end

    QUEUE     = Queue.new
    LOCK      = Mutex.new
    PARSERS   = [
      # order of operations is important here
      #
      # smaller chunks (rt, server offset) should
      # happen before larger, blocking parsers
      # in case they are batched 
      #
      RTDecoder, ServerOffsetDecoder,
      HandsDecoder, 
      StyleDecoder,
      StatusDecoder, ComponentDecoder,
      StreamDecoder,
    ]
    POOL_SIZE = 6

    @@active_parser = nil

    def self.active_parser
      @@active_parser
    end

    def self.reserve(parser)
      LOCK.synchronize do
        ##parser.debug "reserving stream...", :reserve
        @@active_parser = parser
      end
    end

    def self.release!
      LOCK.synchronize do
        ##@@active_parser.debug "releasing stream...", :reserve
        @@active_parser = nil
      end
    end

    def self.dump!
      PARSERS.map do |parser|
        [parser.name.to_sym, parser.fetch]
      end
    end

    def self.strip_xml(string, pattern = XML)
      return string if pattern.match(string).nil?
      strip_xml string.gsub(pattern, ""), pattern
    end

    POOL  = Array.new(POOL_SIZE) do
      Worker.new do
        unless Parser::QUEUE.empty?
          Parser.parse(Parser::QUEUE.shift)
        end
      end
    end

    SUPERVISOR = Worker.new(:parser_pool_supervisor) do      
      POOL.each do |worker|
        unless worker.alive?
          POOL.delete(worker)
          POOL << Worker.new
        end
      end
    end

    def self.<<(raw)
      QUEUE << raw
      self
    end

    def self.parse(incoming)
      return if incoming.strip.empty?
      incoming = incoming.without_line_breaks
      #Norn.log incoming, :incoming
      Try.new do 
        unless active_parser.nil?
          active_parser.update(incoming)
        end
        
        PARSERS.each do |parser|
          parser.update(incoming)
        end
      end
    end
  end
end
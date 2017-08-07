require "ostruct"
require "norn/util/buffer"
require "norn/util/memory-store"
require "norn/util/trait"
require "norn/dsl/tags"

module Decoder
  IDENTITY = Proc.new do |t|
    [:ok, t]
  end
  include Norn::DSL

  with_traits do |args|
    @args    = args
    @store   = MemoryStore.new(self.name)
    @buffer  = Buffer.new
    @open    = @args.open
    @close   = @args.close
    @content = args.content || nil
    @cast    = @args.cast   || IDENTITY
  
    if @close && @content.nil?
      @content = %r{
        #{@open.source}
        (?<content>.*?)
        #{@close.source}
      }xm
    end

    def self.args
      @args
    end
    
    def self.cast(*args)
      @cast.call(*args)
    end

    def self.open(data = nil)
      return @open if data.nil?
      @open.match(data)
    end

    def self.close(data = nil)
      return @close if data.nil?
      # self-closing tag
      return true if @close.nil?
      @close.match(data)
    end

    def self.content_pattern
      @content
    end

    def self.content(data = nil)
      return nil if @content.nil?
      if match = @content.match(data)
        match[:content].strip
      else
        nil
      end
    end

    def self.scan(data)
      (@content || @open).scan(data)
    end

    def self.states
      @store
    end

    def self.buffer
      @buffer
    end

    def self.synchronize(name, data, match)
      #debug match.names, :match
      match = match.to_struct
      # content exists in the tag itself
      if match.content
        did, data = cast(match.content, name, match)
        return put(name, data) if did.ok?
        return [:err, data]    if did.err?
        return [:noop, data]   if did.noop?
      end

      innards = content(data)
      #debug data, :data
      #debug innards, name

      if innards.nil?
        raise Exception.new %{
          unhandled Decoder<#{name}> state:
          data : #{data}
        }
      end

      did, data = cast(innards, name, match)
      
      return [:ok, put(name, data)] if did.ok?
      return [did, data]
    end

    def self.should_parse?
      Norn::Parser.active_parser.nil? || Norn::Parser.active_parser == self
    end

    def self.self_closing?
      @close.nil?
    end

    def self.synchronize_all(incoming)
      return scan(incoming).each do |match|
        synchronize(
          match[:type].to_sym, 
          match.to_s, 
          match)
      end
    end
    
    def self.update(incoming)
      return unless should_parse?    
      closed = close(incoming)
      opened = open(incoming)
      
      #if self == Norn::Parser::StyleDecoder
      #  debug(incoming, :incoming)
      #  debug(opened, :open)  if opened
      #  debug(closed, :close) if @close && closed
      #  debug(buffer.peek, :buffer) unless buffer.empty?
      #end

      if opened && closed && buffer.empty?
        return synchronize_all(incoming)
      end

      # begin chunked transfer
      if opened && buffer.empty?
        Norn::Parser.reserve(self)
        return buffer.push(incoming)
      end
        
      # handle ended chunked transfer
      if !self_closing? && closed && !buffer.empty?
        # handle complete transfer
        buffer.push(incoming)
        buffered = buffer.flush.join
        #debug buffered, :buffer
        match    = open(buffered)
        Norn::Parser.release!
        return match && synchronize_all(buffered)
      end

      if buffer.size > 200
        debug "possible memory leak Buffer<size: #{buffer.size}>"
        buffer.flush
        Norn::Parser.release!
      end

      # handle continued stream
      if Norn::Parser.active_parser == self
        #debug "buffering chunks", :buffer
        buffer.push(incoming)
      end
      
    end

    def self.debug(message, label = :debug)
      if message.is_a?(Exception)
        message = [
          message.message,
          message.backtrace.join("\n"),
        ].join
      end
      puts %{[#{self.name}.#{label}] #{message}}
    end

    def self.normalize_key(key)
      key.to_s.downcase.gsub(/\s+/, "_")
    end

    def self.fetch(key = nil, default = [])
      if key.nil?
        states.fetch(key, default)
      else
        states.fetch(normalize_key(key), default)
      end
    end

    def self.put(key, list)
      states.put normalize_key(key), list
    end
  end
end
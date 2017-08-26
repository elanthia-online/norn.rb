require "norn/util/worker"
require "norn/util/memory-store"
require "norn/util/buffer"
require "norn/parser/tokens"
require "norn/parser/decoder"

module Norn
  module Parser
    class ComponentDecoder
      include Decoder[
        wants: [:component, :compdef],
        attrs: [:id],
        cast: Proc.new do |type, tag, children|
          case tag.id
          when :roomexits
            [:ok, 
              Direction.parse(children)]
          when :roomdesc
            [:ok,
              Room::Description.parse(tag)]
          when :roomplayers
            [:ok,
              Players.parse(children)]
          when :roomobjs
            [:ok,
              Room.put(:objs, 
                GameObj.parse(children))]
          else
            ComponentDecoder.debug("possible data loss in component <#{type}>", type)
            [:ok,
              nil]
          end
        end
      ]
    end

    class StatusDecoder
      include Decoder[
        wants: [:indicator],
        attrs: [:id, :visible],
        cast: Proc.new do |type, state|
          [:ok, 
            Status.parse(type, state)]
        end
      ]
    end

    class StreamDecoder
      include Decoder[
        wants: [:stream],
        cast: Proc.new do |type, tag, children|
          case tag.id
          when :speech
            [:ok, 
              text.text]
          when :thoughts
            [:ok, 
              tag.text]
          # defer to inventory parser
          when :inv 
            [:ok,
              Inv.parse(children)]
          when :room
            [:ok, 
              ComponentDecoder.cast(tag)]
          when :bounty
            #[:ok, 
            #  Bounty.parse(tag.text)]
          end
        end
      ]
    end

    class StyleDecoder
      include Decoder[
        wants: [:style],
        cast: Proc.new do |type, tag, children|
          case tag.id
          when :roomdesc
            [:ok,
              Room::Description.parse(tag)]
          when :roomname
            [:ok,
              Room.put(:title, tag.text)]
          else
            StyleDecoder.debug(tag, :possible_data_loss)
          end
        end
      ]
    end

    class HandDecoder
      include Decoder[
        wants: [:left, :right],
        cast: Proc.new do |id, tag, children|
          [:ok,  
            Hand.new(
              tag.name, 
              tag.fetch(:id), 
              tag.fetch(:noun), 
              tag.fetch(:desc))]
        end
      ]
    end

    class RTDecoder
      include Decoder[
        wants: [:roundtime, :casttime],
        cast: Proc.new do |type, tag, children|
          [:ok, 
            Roundtime.put(tag.name, tag.fetch(:value))]
        end
      ]
    end

    STATE     = MemoryStore.new(:parser, {
      tags:   [],
      stream: nil,
    })
    BUFFER    = Buffer.new
    QUEUE     = Queue.new
    LOCK      = Mutex.new
    POOL_SIZE = 4

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

    def self.state
      Parser::STATE.access do |state|
        yield state
      end
    end

    def self.clear!
      state do |state|
        state[:stream] = nil
        state[:tags]   = []
      end
    end

    def self.parse(incoming)
      Norn.log incoming, :incoming
      tokens = BUFFER.flush + incoming.chars
      Parser::STATE.access do |state|
        while tokens.size > 0
          Parser.ingest(tokens.shift, tokens, state[:tags], state)
        end
        state
      end
    end
    ##
    ## ingest a raw token stream
    ##
    def self.ingest(token, tokens, tags, state)
      return Parser.tag(tokens, tags, state) if token == Tokens::OPEN_TAG
      tags.last + token unless tags.last.nil? || tags.last.closed?
    end
    ##
    ## parse an incoming tag
    ##
    def self.tag(tokens, tags, state)
      #Norn.log(tokens.join, :parser_tag)
      tag = Tag.new(tags.last)
      ##
      ## consume tag name
      ##
      name = ""
      while (next_char = tokens.shift)
        # <tag id='123'> so we need to parse attributes
        break if next_char == Tokens::WHITESPACE
        # <popTag/>
        break if next_char == Tokens::SELF_CLOSING_TAG && name.start_with?(Tokens::POP)
        # <pushTag/>
        break if next_char == Tokens::SELF_CLOSING_TAG && name.start_with?(Tokens::PUSH)
        # <b
        break if next_char == Tokens::CLOSE_TAG && name == Tokens::NORMAL_BOLD

        # <tag/>
        if next_char == Tokens::SELF_CLOSING_TAG && state[:stream].nil? && !name.empty?
          #Norn.log(name, :self_closing_root)
          tag.name  = name
          tag.attrs = ""
          tag.close
          return Parser.emit(tag.name, tag)
        end

        # <tag> with empty attribute set
        if next_char == Tokens::CLOSE_TAG
          tag.name = name
          tag.attrs = ""
          return tags << tag
        end

        # </tag...>
        if name.empty? && next_char == Tokens::SELF_CLOSING_TAG
          ff = fast_forward(tokens)
  
          return if ff == Tokens::NORMAL_BOLD

          tag = tags.pop
          #
          # we want to drop this tag
          return if tag.nil?
          # seal the tag
          tag.close
          # if was root tag & we are in a stream
          # add it to the stream
          if tags.empty? && state[:stream]
            return state[:stream] << tag
          end
          # if we are on a root tag
          # emit it to the world
          if tags.empty?
            #Norn.log(tag, :tag_close_quick)
            return Parser.emit(tag.name, tag)
          # add the child text & itself to the existing root
          else
            #Norn.log(tags.first, :tags)
            # peek ahead for after name things
            if tag.name == :a && tags.last.id != :roomdesc
              after_content, tail = peek(tokens)
             
              unless after_content.empty?
                tag.put(:tail, after_content) 
                #Norn.log after_content, :a_after_content
              end
              tags.last + tag.text unless tag.text.nil?
              tags.last + tail     unless tail.nil?
              tag.close
              return tags.last << tag
            end

            tags.last + tag.text unless tag.text.nil?
            return tags.last << tag
          end
        end
        name = name + next_char
      end
      # Norn.log(name, :tag_name_raw)
      ##
      ## open stream
      ##
      if name.start_with?(Tokens::PUSH)
        #Norn.log("entering stream #{tag.fetch(:id)}", :stream_open)
        name = name.downcase.slice(Tokens::PUSH_LENGTH, 
          name.size)
        state[:stream] = tag if name.to_sym == :stream
      end
      ##
      ## close stream
      ##
      if name.start_with?(Tokens::POP) #&& state[:stream]
        #Norn.log("ending stream #{state[:stream].fetch(:id)} -> #{name}", :stream_close)
        name = name.downcase[Tokens::POP_LENGTH..-1]
        if name.to_sym == :stream
          tag = tags.pop
          tag.close
          state[:stream] = nil
          return Parser.emit(tag.name, tag)
        end
      end

      tag.name = name

      return if tag.name == :streamwindow
      ##
      ## sometime these tags are sent instead of popStream
      ## wtf is that nonsense?
      ##
      if [:component, :compdef].include?(tag.name) && state[:stream]
        Norn.log(state[:stream], :dangling_stream_recovery)

        dangler = state[:stream].close
        
        state[:stream] = nil

        tags.pop if tags.last == dangler

        Parser.emit(dangler.name, dangler)
      end

      if tag.name == :bold || tag.name == :b
        #Norn.log(name, :drop_tag)
        return fast_forward(tokens) # drop ancillary data early
      end

      # Norn.log(tag, tag.name)

      ###
      ### parse attrs part of tag
      ###
      attrs = ""
      while (next_char = tokens.shift)
        break if next_char == Tokens::CLOSE_TAG

        # <style id="<something>" />
        if next_char == Tokens::SELF_CLOSING_TAG && tag.name == :style
          fast_forward(tokens)
          break
        end

        # dialogData kith & kin
        if next_char == Tokens::SELF_CLOSING_TAG && state[:stream].nil? && !tags.last.nil?
          #Norn.log(name, :self_closing_child)
          tag.attrs = attrs.strip
          tag.close
          return tags.last << tag
        end
        
        # <status attr="123"/>
        # but not <a href='http://taters.com'>"
        if next_char == Tokens::SELF_CLOSING_TAG && state[:stream].nil? && tokens.first == Tokens::CLOSE_TAG
          #Norn.log(name, :self_closing_attr_tag)
          tag.attrs = attrs.strip
          tag.close
          return Parser.emit(tag.name, tag)
        end
        attrs = attrs + next_char
      end
      tag.attrs = attrs.strip
      ##
      ## handle garbage style tags
      ##
      if tag.name == :style
        #Norn.log(tag, :style)
        ## discard style flushes that precede style blocks
        return if tag.fetch(:id).empty? && tags.last.nil?
        ## 
        if tag.fetch(:id).empty? && tags.last.name == :style
          tag = tags.pop
          tag.close
        end
      end
      
      #Norn.log(tag, :tag)
      return Parser.emit(tag.name, tag) if tag.closed? && tag.is_parent? && state[:stream].nil?
      tags << tag
    end
    ##
    ## used for fast-forwarding a token stream to a particular token
    ##
    def self.fast_forward(tokens, to = Tokens::CLOSE_TAG)
      ff = []
      while tokens.size
        ff << tokens.shift
        break if ff.last == to
      end
      ff.pop # remove /
      return ff.join
    end

    def self.peek(tokens, stop_words: Tokens::STOP_WORDS, stop_tokens: Tokens::STOP_TOKENS)
      ahead  = ""
      bound  = nil
      # don't modify the original token-set
      # unless we are sure we want to
      cp = tokens.clone
      #Norn.log(cp, :peek)
      while cp.size
        token = cp.shift

        break if token.nil?

        if token == Tokens::OPEN_TAG
          fast_forward(cp)
          next
        end

        if stop_tokens.include?(token)
          bound = token
          break
        end
        #Norn.log(ahead, :peek_ahead)
        #Norn.log(token, :peek_token)
        ahead = ahead + token
        if stop_word = stop_words.find do |stop| ahead.end_with?(stop) end
          # remove the stop word from the end of the look ahead
          bound = stop_word
          ahead = ahead[0..-stop_word.size-1]
          break
        end
      end
      ahead.size.times do tokens.shift end
      return [ahead.strip, ahead + (bound || "")]
    end

    ##
    ## send a parsed Tag to the world
    ##
    def self.emit(type, tag)
      Norn.log(tag, :emit)
      Decoder.each do |decoder|
        decoder.cast(tag) if decoder.wants?(type)
      end
    end
  end
end
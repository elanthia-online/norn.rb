module Norn
  class Parser
    ##
    ## Implements interface for 
    ## SAX-style callbacks &
    ## custom GS-specific callbacks
    ##
    class Callbacks
      attr_reader :stack, :world_callbacks
      ##
      ## setup stream state
      #
      def initialize(world_callbacks = nil)
        @stack           = Array.new
        @world_callbacks = world_callbacks
      end
      ##
      ## SAX parser callbacks
      ##
      def on_element(_, name, attrs = {})
        @stack << Tag.new(name, attrs)
      end
      ##
      ## add the text to the last element in the Stack
      ##
      def on_text(text)
        return if @stack.empty?
        @stack.last + text
      end
      ##
      ## handle Stack operations
      ##
      def after_element(_, name)
        if stack.size > 1
          child  = @stack.pop
          prev   = @stack.last
          #Norn.log(stack, :stack)
          # parent is a monster
          if prev.is?(:monster) && child.is?(:a) && prev.attrs.empty?
            # monsters eat their children
            return prev.merge(child)
          # /monster/monster/monster === <monster>
          elsif prev.is?(:monster) && (child.is?(:monster) || child.is?(:b))
            return prev.merge(child)
          # siblings
          elsif (prev.is?(:monster) || prev.is?(:a)) && child.is?(:a)
            #Norn.log(child, :siblings)
            return prev.parent.children << child
          else
            child.parent = prev
            child.parent + child.text
            @stack.last.children << child
          end
        else
          on_gs_tag @stack.pop
        end
      end
      ##
      ## callback for SAX errors
      ##
      def parser_error(*args)
        Norn.log(args, :sax_error)
      end
      ##
      ## GS-specific callbacks
      ##
      def on_gs_tag(tag)
        return if EDGE_NODES.include?(tag.name)
        return if world_callbacks.nil?
        ##
        ## delegate this tag to World callbacks
        ## if they exist
        ##
        unless tag.callbacks.any? do |cb| world_callbacks.respond_to?(cb) end
          world_callbacks.on_unhandled(tag)
        else
          tag.callbacks.each do |callback|
            if world_callbacks.respond_to?(callback)
              world_callbacks.send(callback, tag)
            end
          end
        end
      end
    end
  end
end
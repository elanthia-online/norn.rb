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
      def initialize(callbacks)
        @stack           = Array.new
        @world_callbacks = callbacks
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
        if status = Status.match(text)
          child = @stack.last.children.last
          child.attrs[:status] = status unless child.nil?
        end
        @stack.last + text
      end
      ##
      ## handle Stack operations
      ##
      def after_element(_, name)
        if stack.size > 1
          child  = @stack.pop
          prev   = @stack.last
          # parent is a monster
          if prev.is?(:monster) && child.is?(:a) && prev.attrs.empty?
            # monsters eat their children
            return prev.merge(child)
          # /monster/monster/monster === <monster>
          elsif prev.is?(:monster) && (child.is?(:monster) || child.is?(:b))
            return prev.merge(child)
          # siblings
          elsif (prev.is?(:monster) || prev.is?(:a)) && child.is?(:a) && prev.parent
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
        System.log(args, label: :sax_error)
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
        @world_callbacks.each do |dispatcher|
          unless tag.callbacks.any? do |cb| dispatcher.respond_to?(cb) end
             dispatcher.on_unhandled(tag) if dispatcher.respond_to?(:on_unhandled)
          else
            tag.callbacks.each do |callback|
              if dispatcher.respond_to?(callback)
                dispatcher.send(callback, tag)
              end
            end
          end
        end
      end
    end
  end
end
module Norn
  module Parser
    class Tag
      ##
      ## all modes a tag can be in
      ##
      module Modes
        IN_TAG_NAME     = :in_tag_name
        IN_TAG_ATTRS    = :in_tag_attrs
        IN_TAG_CONTENTS = :in_tag_contents
        CLOSED          = :closed
      end

      class InvalidTagMode < Exception
        def initialize(tag, arg)
          super("invalid TagMode #{tag} -> #{arg}")
        end
      end

      ATTR = /(?<prop>[a-z]+)=("|')(?<val>.*?)("|')/

      attr_reader :name, :mode, 
                  :children, :parent, 
                  :text, :attrs, :id

      def initialize(parent=nil)
        @mode     = Modes::IN_TAG_NAME
        @parent   = parent unless parent.nil?
        @attrs    = Hash.new
        @children = []
      end

      def name=(name)
        raise InvalidTagMode.new(self, name) unless in_tag_name?
        @name = name.downcase.to_sym
        @mode = Modes::IN_TAG_ATTRS
        self
      end

      def attrs=(attr_str)
        raise InvalidTagMode.new(self, attr_str) unless in_tag_attrs?
        
        @mode = Modes::IN_TAG_CONTENTS

        return self if attr_str.empty?

        attr_str.scan(ATTR).each do |prop, contents|
          @attrs[prop.to_sym] = contents.strip
        end

        if @attrs[:id]
          @id = @attrs[:id].gsub(/\s+/, '').downcase.to_sym
        end
       
        self
      end

      def fetch(prop)
        @attrs[prop.to_sym]
      end

      def put(prop, val)
        @attrs[prop.to_sym] = val
        self
      end

      def <<(child)
        raise InvalidTagMode.new(self, child) unless in_tag_contents?
        @children << child
        self
      end

      def +(text)
        raise InvalidTagMode.new(self, text) unless in_tag_contents?
        @text ||= ""
        @text = (@text + text).gsub(/\s+/, " ")
        self
      end

      def close
        @text = @text.strip
        @mode = Modes::CLOSED
        self
      end

      def is_parent?
        @parent.nil?
      end

      def in_tag_name?
        @mode == Modes::IN_TAG_NAME
      end
      
      def in_tag_attrs?
        @mode == Modes::IN_TAG_ATTRS
      end

      def in_tag_contents?
        @mode == Modes::IN_TAG_CONTENTS
      end

      def closed?
        @mode == Modes::CLOSED
      end

      def open?
        !closed?
      end

      def to_s
        tag = "<#{@name} @mode=#{@mode}"
        #tag = tag + " @parent=#{@parent.name}" unless @parent.nil?
        tag = tag + " #{@attrs}"
        tag = tag + " #{@children}" unless @children.empty?
        tag = tag + ">"
        tag = tag + @text unless @text.nil?
        tag = tag + "</#{@name}>" if closed?
        tag
      end
    end
  end
end
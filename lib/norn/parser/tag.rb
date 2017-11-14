require 'forwardable'

module Norn
  class Parser
    class Tag
      extend Forwardable
      MAPPINGS = {
        b: :monster
      }

      def self.normalize_name(tag)
        MAPPINGS.fetch(tag, tag)
      end
      ##
      ## find the first match in a Tag tree
      ##
      def self.find(tag, name)
        return tag if tag.name.eql?(name)
        children = tag.children.clone
        until children.empty?
          found = find(children.shift, name)
          return found unless found.nil?
        end
        nil
      end
      ##
      ## parse a Tag tree
      ##
      def self.by_name(tag, name, results = [])
        results << tag if tag.name.eql?(name)
        tag.children.each do |child|
          Tag.by_name(child, name, results)
        end
        results
      end
      ##
      ## normalize the Id value
      ##
      def self.normalize_id_value(id)
        # don't cast GameObj ids to Symbol
        return id if id.is_i?
        # downcase it
        id = id.downcase
        # normalize <indicator> id
        # ex: IconSTUNNED => :stunned
        return id.gsub("icon", "").to_sym if id.start_with?("icon")
        # normalize other ids
        id.gsub(/\s+/, "_").gsub("-", "_").to_sym
      end
      ##
      ## normalize an attr, value pair
      ##
      def self.normalize_attr(k, v)
        k = k.to_sym
        return [k, Tag.normalize_id_value(v)]  if k.eql?(:id)
        return [k, v.downcase.eql?("y")] if k.eql?(:visible)
        return [k, v]
      end
      ##
      ## normalize a Hash of attributes
      ##
      def self.normalize_attrs(attrs = {})
        Hash[attrs.map do |k, v| 
          Tag.normalize_attr(k, v)
        end]
      end
      ##
      ## create a single callback symbol
      ##
      def self.callback(name, id = nil)
        callback = ["on"]
        callback << name
        callback << id unless id.nil?
        callback.join("_").downcase.to_sym
      end
      ##
      ## create a list of callbacks for a tag
      ## 
      ## TODO: memoize this
      ##
      def self.callbacks(name, id = nil)
        ## less specific callback
        callbacks = [callback(name)]
        ## more specific callback
        callbacks << callback(name, id) unless id.nil?
        callbacks
      end
      ##
      ## read-only refs
      ##
      attr_reader :name, :attrs,
                  :children, :callbacks
      ##
      ## read + write refs
      ##
      attr_accessor :text, :parent

      def_delegators :@attrs, :fetch

      def initialize(name, attrs)
        @name      = Tag.normalize_name(name.gsub("-", "_").downcase.to_sym)
        @attrs     = Tag.normalize_attrs(attrs)
        @callbacks = []
        @callbacks = Tag.callbacks(@name.to_s, id) unless EDGE_NODES.include?(@name)
        @children  = []
      end

      def id
        @attrs.fetch(:id, nil)
      end

      def is?(type)
        @name.eql?(type)
      end

      def +(text)
        return if text.nil?
        @text = (@text || "") + text
      end

      def merge(other)
        @text  = other.text
        @attrs = @attrs.merge(other.attrs)
        self
      end

      def to_gameobj
        {
          id: fetch(:exist), 
          name: text,
          noun: fetch(:noun),
          status: fetch(:status, []),
        }
      end

      def to_s
        out = %{<#{name} #{attrs} } 
        out.concat %{ #{children.map(&:to_s)}} unless children.empty?
        out.concat %{ cbs=#{callbacks}} unless callbacks.empty?
        out.concat %{ text=#{text}>} if text
        out.concat %{>}
        out
      end

      def inspect
        to_s
      end
    end
  end
end
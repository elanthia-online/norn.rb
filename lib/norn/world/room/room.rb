require "norn/util/memory-store"
require "norn/parser/tag"
module Norn
  class Room < MemoryStore
    Tag = Norn::Parser::Tag
    ##
    ## increments the number of Rooms seen
    ## during this session
    ##
    def inc
      put(:count, 
        fetch(:count, 0) + 1)
    end

    def count
      fetch :count, 0
    end

    def id
      fetch :id
    end

    def title
      fetch :title
    end

    def desc
      fetch :desc
    end

    def exits
      fetch :exits, []
    end

    def objs
      fetch :objs, []
    end

    def monsters
      objs.select do |obj|
        obj.is_a?(Monster)
      end
    end

    def items
      objs.select do |obj|
        obj.is_a?(Item)
      end
    end

    def players
      fetch :players, []
    end

    def self.to_monsters_or_items(tags)
      tags.map do |tag|
        case tag.name
        when :monster
          Monster.new(**tag.to_gameobj)
        when :a
          Item.new(**tag.to_gameobj)
        else
          raise Exception.new %{
            unhandled Description descendent
            #{tag.inspect}
          }
        end
      end
    end

    class Description
      def self.of(tag)
        new(tag.text, 
          Room.to_monsters_or_items(tag.children))
      end

      attr_accessor :text, :objs

      def initialize(text, objs)
        @text = text
        @objs = objs
      end

      def monsters
        objs.select do |obj|
          obj.is_a?(Monster)
        end
      end

      def items
        objs.select do |obj|
          obj.is_a?(Item)
        end
      end

      def to_json(opts = {})
        {text: text, objs: objs.map(&:to_json)}.to_json(opts)
      end

    end

    class Exit
      def self.of(tag)
        new(tag.fetch(:value, 
          tag.fetch(:text, nil)))
      end

      attr_accessor :dir

      def initialize(dir)
        @dir = dir
      end

      def to_json(opts = {})
        self.dir.to_s
      end
    end
  end
end
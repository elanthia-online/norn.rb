require "norn/util/memory-store"
require "norn/parser/tag"

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

  class Description < Struct.new(:text, :objs)
    def self.of(tag)
      new(tag.text, 
        Room.to_monsters_or_items(tag.children))
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
  end

  class Exit < Struct.new(:dir)
    def self.of(tag)
      new(tag.fetch(:value, 
        tag.fetch(:text, nil)))
    end
  end
end
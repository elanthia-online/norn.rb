require "norn/parser/parser"
require "norn/util/memory-store"
require "norn/world/gameobj"

class Room
  @@store = MemoryStore.new

  def self.fetch(*args)
    @@store.fetch *args
  end

  def self.put(*args)
    @@store.put *args
  end
  ##
  ## backwards compat
  ##
  def self.current
    self
  end

  def self.id
    fetch :id
  end

  def self.title
    fetch :title
  end

  def self.exits
    fetch :exits, []
  end

  def self.desc
    fetch :desc
  end

  def self.objs
    fetch :objs, []
  end

  def self.players
    Players.fetch || []
  end

  class Description < Struct.new(:text, :objs)
    def self.parse(contents)
      objs = GameObj.parse(contents)
      text = Norn::Parser.strip_xml(contents)
      new(text, objs)
    end

    def initialize(*args)
      super *args
      Room.put :desc, self
    end
  end
end

class Array
  def to_dirs
    self.map do |data|
      Direction.new *data
    end
  end
end

class Direction < Struct.new(:dir)
  def self.parse(str)
    Room.put :exits, str.scan(Norn::Parser::Tags::D).to_dirs
  end

  def go
    World.send("go #{dir}")
  end
end
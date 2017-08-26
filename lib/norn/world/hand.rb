require "norn/world/gameobj"

class Hand < GameObj
  Empty   = Hand.new(:empty, :empty, :empty)
  @@store = MemoryStore.new

  def self.fetch(*args)
    @@store.fetch *args
  end

  def self.put(*args)
    @@store.put *args
  end

  def self.left
    fetch :left, Empty
  end
  
  def self.right
    fetch :right, Empty
  end

  def self.new(type, id, noun, desc)
    hand = if id.nil?
       Empty
    else
      super(id, noun, desc)
    end
    Hand.put(type, hand)
  end

  def empty?
    id == :empty
  end
end

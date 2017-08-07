require "norn/util/registry"
require "norn/world/gameobj"
require "norn/parser/parser"

class Inv
  REGISTRY = Registry.new(:id, :noun, :name)

  def self.parse(inv)
    REGISTRY.put *GameObj.parse(inv)
  end

  def self.fetch(*args)
    REGISTRY.fetch *args
  end
end
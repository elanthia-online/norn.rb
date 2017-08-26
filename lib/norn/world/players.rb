require "norn/util/registry"
require "norn/world/gameobj"
require "norn/world/status"

class Players
  REGISTRY = Registry.new(:id, :noun, :name)

  def self.parse(players)
    REGISTRY.put *GameObj.parse(players).map(&:to_player)
  end

  def self.fetch(*args)
    REGISTRY.fetch *args
  end
end

class Player < GameObj
  include Status::Effects
end

class GameObj
  def to_player
    Player.new(id, noun, name, status, tags)
  end
end
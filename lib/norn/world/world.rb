require "norn/world/callbacks"

class World
  attr_reader :callbacks,
              :roundtime, :status,
              :room, :hands, :containers,
              :stance, :char
              
  def initialize()
    @callbacks  = World::Callbacks.new(self)
    @roundtime  = Roundtime.new
    @status     = Status.new
    @room       = Room.new
    @hands      = Hands.new
    @containers = Containers.new
    @stance     = Stance.new
    @char       = Char.new
  end
end
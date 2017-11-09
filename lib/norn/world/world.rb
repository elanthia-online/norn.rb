require "norn/world/callbacks"

class World
  attr_reader :callbacks,
              :roundtime, :status,
              :room, :hands, :containers
              
  def initialize()
    @callbacks  = World::Callbacks.new(self)
    @roundtime  = Roundtime.new
    @status     = Status.new
    @room       = Room.new
    @hands      = Hands.new
    @containers = Containers.new
  end
end
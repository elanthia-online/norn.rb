require "norn/world/callbacks"

class World
  attr_reader :callbacks,
              :roundtime, :status,
              :room, :hands, :containers,
              :stance, :char, :mind, :bounty,
              :scars, :injuries, :spells,
              :encumb, :health, :mana, :stamina, :spirit,
              :stats, :silver, :inv
              
  def initialize()
    @callbacks  = [World::Callbacks.new(self)]
    @roundtime  = Roundtime.new
    @status     = Status.new
    @room       = Room.new
    @hands      = Hands.new
    @containers = Containers.new
    @stance     = Stance.new
    @inv        = Inv.new
    @silver     = Silver.new
    @char       = Char.new
    @injuries   = Injuries.new
    @scars      = Scars.new
    @mind       = Mind.new
    @bounty     = Bounty.new
    @stats      = Stats.new
    @spells     = Spells.new
    @encumb     = Encumb.new
    @mana       = Mana.new
    @stamina    = Stamina.new
    @health     = Health.new
    @spirit     = Spirit.new
  end

  def context()
    instance_variables.map do |prop|
      instance_variable_get(prop)
    end
  end

  def get_context_for(name)
    instance_variable_get(%{@#{name}}.to_sym)
  end
end
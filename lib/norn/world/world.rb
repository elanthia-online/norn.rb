require "norn/world/callbacks"

module Norn
  class World
    attr_reader :callbacks,
                :roundtime, :status,
                :room, :hands, :containers,
                :stance, :char, :mind, :bounty,
                :scars, :injuries, :spells, :map,
                :encumb, :health, :mana, :stamina, :spirit,
                :stats, :silver, :inv, :exports
                
    def initialize()
      ##
      ## this is an Array(Callbacks) 
      ## that any script may attach callbacks
      ## directly to, but they must be cleaned up
      ## after the script dies
      ##
      @callbacks  = [World::Callbacks.new(self)]
      ##
      ## all World properties we want to track
      ## the state of
      ##
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
      @exports    = Exports.new
      @map        = Norn::Map.load()
    end

    def context()
      instance_variables.map do |prop|
        [prop.slice(1, prop.length), 
          instance_variable_get(prop)]
      end
    end

    def get_context_for(name)
      instance_variable_get(%{@#{name}}.to_sym)
    end
  end
end
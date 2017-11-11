require "norn/util/memory-store"
require "norn/util/percentage"

class Stance < MemoryStore
  include Percentage
  
  OFFENSIVE = :offensive
  ADVANCE   = :advance
  FORWARD   = :forward
  NEUTRAL   = :neutral
  GUARDED   = :guarded
  DEFENSIVE = :defensive
  ENUM      = [OFFENSIVE, ADVANCE, 
               FORWARD, NEUTRAL, 
               GUARDED, DEFENSIVE]

  ENUM.each do |stance|
    send(:define_method, stance.to_boolean_method) do
      fetch(:current, nil).eql?(stance)
    end
  end
end
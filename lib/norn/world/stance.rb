require "norn/util/memory-store"

class Stance < MemoryStore
  OFFENSIVE = :offensive
  ADVANCE   = :advance
  FORWARD   = :forward
  NEUTRAL   = :neutral
  GUARDED   = :guarded
  DEFENSIVE = :defensive
  ENUM      = [OFFENSIVE, ADVANCE, 
               FORWARD, NEUTRAL, 
               GUARDED, DEFENSIVE]

  def percent
    fetch(:percent, 0)
  end

  def gt?(val)
    percent > 0
  end

  def lt?(val)
    percent < 0
  end

  def eql?(val)
    percent.eql?(val)
  end

  ENUM.each do |stance|
    send(:define_method, stance.to_boolean_method) do
      fetch(:current, nil).eql?(stance)
    end
  end
end
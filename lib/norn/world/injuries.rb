require "norn/util/memory-store"

class Injuries < MemoryStore
  MAPPINGS = {
    injury1: 1,
    injury2: 2,
    injury3: 3,
  }

  def self.decode(injury)
    result = MAPPINGS.fetch(injury, nil)
    return [:injury, result] if result
    return false
  end

  def total
    values.reduce(0, &:+)
  end

  def method_missing(method, fallback = 0)
    fetch(method, fallback)
  end
end
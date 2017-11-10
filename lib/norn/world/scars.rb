require "norn/util/memory-store"

class Scars < MemoryStore
  MAPPINGS = {
    scar1: 1,
    scar2: 2,
    scar3: 3,
  }

  def self.decode(scar)
    result = MAPPINGS.fetch(scar, nil)
    return [:scar, result] if result
    return false
  end

  def method_missing(method, fallback = 0)
    fetch(method, fallback)
  end
end
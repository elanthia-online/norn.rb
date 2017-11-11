require "norn/util/memory-store"
require "norn/world/vital"

class Health < MemoryStore
  include Vital
end
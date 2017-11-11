require "norn/util/memory-store"
require "norn/util/percentage"

class Health < MemoryStore
  include Percentage
end
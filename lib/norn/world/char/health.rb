require "norn/util/memory-store"
require "norn/util/percentage"

module Norn
  class Health < MemoryStore
    include Percentage
  end
end
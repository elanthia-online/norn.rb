require "norn/util/memory-store"
require "norn/util/percentage"

module Norn
  class Stamina < MemoryStore
    include Percentage
  end
end
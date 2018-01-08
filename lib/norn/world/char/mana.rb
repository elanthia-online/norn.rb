require "norn/util/memory-store"
require "norn/util/percentage"

module Norn
  class Mana < MemoryStore
    include Percentage
  end
end
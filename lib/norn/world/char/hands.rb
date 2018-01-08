require "norn/util/memory-store"

module Norn
  class Hands < MemoryStore
    def left
      fetch(:left, nil)
    end

    def right
      fetch(:right, nil)
    end
  end
end
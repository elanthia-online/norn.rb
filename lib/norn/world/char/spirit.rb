require "norn/util/memory-store"
require "norn/util/percentage"

module Norn
  class Spirit < MemoryStore
    include Percentage
  end
end
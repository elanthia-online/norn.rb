require "norn/util/memory-store"
require "norn/world/bounty/parser"

module Norn
  class Bounty < MemoryStore
    def self.parse(str)
      Bounty::Parser.parse(str.strip)
    end
  end
end
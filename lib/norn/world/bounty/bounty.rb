require "norn/util/memory-store"
require "norn/world/bounty/parser"

class Bounty < MemoryStore
  def self.parse(str)
    Bounty::Parser.parse(str.strip)
  end
end
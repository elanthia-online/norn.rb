require "norn/util/memory-store"

module Norn
  class Containers < MemoryStore
    def self.stow
      fetch(Char.fetch(:stow_container_id, nil), nil)
    end
  end
end
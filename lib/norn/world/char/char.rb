require "norn/util/memory-store"

module Norn
  class Char < MemoryStore
    def name
      fetch(:char, :err)
    end

    def game
      fetch(:game, :err)
    end

    def title
      fetch(:title, :err)
    end

    def method_missing(method, *args)
      fetch(method, *args)
    end
  end
end
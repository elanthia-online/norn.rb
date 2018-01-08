require "norn/util/memory-store"

module Norn
  class Roundtime < MemoryStore

    def offset(time = nil)
      return fetch(:offset) if time.nil?
      put(:offset, Time.now.to_i - time.to_i)
    end

    def put(type, timestamp)
      super(type.downcase, timestamp.to_i)
    end

    def fetch(type = nil)
      super(type.downcase, 0)
    end

    def rt
      [fetch(:roundtime) - Time.now.to_f + offset + 0.6, 0].max
    end

    def castrt
      [fetch(:casttime) - Time.now.to_f + offset + 0.6, 0].max
    end

    def castrt?
      castrt > 0
    end

    alias_method :soft?, :castrt?

    def rt?
      rt > 0
    end

    alias_method :hard?, :rt?

    def cast_rt!
      sleep castrt while castrt?
    end

    def hard_rt!
      sleep rt while rt?
    end
  end
end
require "norn/util/memory-store"

module Norn
  class Injuries < MemoryStore
    MAPPINGS = {
      injury1: 1,
      injury2: 2,
      injury3: 3,
    }

    AREA_MAPPINGS = {
      rightleg: :right_leg,
      rightarm: :right_arm,
      righteye: :right_eye,
      leftleg:  :left_leg,
      leftarm:  :left_arm,
      lefteye:  :left_eye,
      nsys:     :nerves,
    }

    def self.decode(injury)
      result = MAPPINGS.fetch(injury, nil)
      return [:injury, result] if result
      return false
    end

    def self.decode_area(area)
      AREA_MAPPINGS.fetch(area, area)
    end

    def total
      values.reduce(0, &:+)
    end

    def method_missing(method, fallback = 0)
      fetch(method, fallback)
    end
  end
end
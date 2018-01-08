require "norn/util/memory-store"

module Norn
  class Status < MemoryStore
    module DSL
      MONSTER_VERBOSE_EFFECT = %r{that appears (?:to be |)(?<effect>\w+)($|,|.)}
      PLAYER_VERBOSE_EFFECT  = %r{who (is|appears to be) (?<effect>\w+)($|,|.)}
      BRIEF_EFFECT           = %r{\((?<effect>\w+)\)($|,|.)}
    end

    module Effects
      DEAD      = :dead
      PRONE     = :prone
      KNEELING  = :kneeling
      SITTING   = :sitting
      STUNNED   = :stunned
      SLEEPING  = :sleeping
      FROZEN    = :frozen
      WEBBED    = :webbed
      ROOTED    = :rooted
      FLYING    = :flying

      def respond_to_missing?(method_name, include_private = false)
        method_name.is_boolean_method? || super
      end

      def method_missing(*args)
        if args.first.is_boolean_method?
          return status.include?(args.first.from_boolean_method)
        end
        super *args
      end
    end

    def self.match(text)
      found = false
      return found if found = Status.parse(text, DSL::BRIEF_EFFECT)
      return found if found = Status.parse(text, DSL::MONSTER_VERBOSE_EFFECT)
      return found if found = Status.parse(text, DSL::PLAYER_VERBOSE_EFFECT)
      return found
    end

    def self.parse(pattern, text)
      if found = text.match(pattern)
        return found[:effect].split(",").map(&:strip).map(&:to_sym)
      end
      return false
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.is_boolean_method? || super
    end

    def method_missing(*args)
      if args.first.is_boolean_method?
        return fetch(
          args.first.from_boolean_method, 
          false,
        )
      end
      super *args
    end
  end
end
require "norn/util/memory-store"

class Status < MemoryStore
  module DSL
    MONSTER_VERBOSE_EFFECT = %r{that appears (?:to be |)(?<effect>\w+)(\b,|.)}
    PLAYER_VERBOSE_EFFECT  = %r{who (is|appears to be) (?<effect>\w+)(\b,|.)}
    BRIEF_EFFECT           = %r{\((?<effect>\w+)\)(,|.)}
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

  ALSO_HERE_SIZE    = %{Also here: }.size
  ALSO_SEE_SIZE     = %{You also see }.size
  STATUS            = %r{(?<name>\w+) \((?<status>.*?)\)$}
  VERBOSE_EFFECT    = %{(who|that) is}

  def self.match(text)
    return found if found = Status.parse(text, DSL::BRIEF_EFFECT)
    return found if found = Status.parse(text, DSL::MONSTER_VERBOSE_EFFECT)
    return found if found = Status.parse(text, DSL::PLAYER_VERBOSE_EFFECT)
    return false
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
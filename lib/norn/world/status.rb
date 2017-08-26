require "norn/util/memory-store"

module Status
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

  @@store   = MemoryStore.new(:status_effects)

  def self.cast(state)
    state.downcase == "y"
  end

  def self.parse(type, state)
    @@store.put type.slice(4, type.size).downcase, cast(state)
  end

  def self.fetch(*args)
    @@store.fetch *args
  end

  def self.respond_to_missing?(method_name, include_private = false)
    method_name.is_boolean_method? || super
  end

  def self.method_missing(*args)
    if args.first.is_boolean_method?
      return fetch(
        args.first.from_boolean_method, 
        false,
      )
    end
    super *args
  end


end
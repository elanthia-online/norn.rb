require "norn/util/memory-store"

class Encumb < MemoryStore
  def percent
    fetch(:percent, 0)
  end

  def level
    fetch(:level, :none)
  end

  def gt?(val)
    percent > val
  end

  def lt?(val)
    percent < val
  end

  def eql?(val)
    percent.eql?(val)
  end

  def max?
    percent >= 100
  end

  def respond_to_missing?(method_name, include_private = false)
    method_name.is_boolean_method? || super
  end

  def method_missing(*args)
    return level.eql?(args.first.from_boolean_method) if args.first.is_boolean_method?
    super *args
  end
end
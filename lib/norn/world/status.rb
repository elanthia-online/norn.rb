require "norn/util/memory-store"

class Status < MemoryStore
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

  ALSO_HERE_SIZE = %{Also here: }.size
  STATUS = %r{(?<name>\w+) \((?<status>.*?)\)$}

  def self.parse_also_here(str)
    parse_effects(str, ALSO_HERE_SIZE)
  end

  def self.parse_effects(str, offset)
    Hash[str.slice(offset, str.size).split(", ").map do |info|
      ## handle FLAG ROOMBRIEF OFF
      if info.include?("who is")
        info = info.gsub("who is ", "(").concat(")")
      end
      name, status = info.split(" (")
      name = name.split(" ").last
      if status.nil?
        [name, []] 
      else
        [name, status.slice(0, status.size-1).split(",").map(&:to_sym)]
      end
    end]
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
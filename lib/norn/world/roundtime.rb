require "norn/util/memory-store"

class NilClass
  def downcase
    self
  end
end

module Roundtime
  @@store = MemoryStore.new(self.name)
  @@lock  = Mutex.new

  def self.offset(time = nil)
    return @@store.fetch(:offset, 0) if time.nil?
    @@store.put(:offset, Time.now.to_i - time)
  end

  def self.put(type, timestamp)
    @@store.put(type.downcase, timestamp.to_i)
  end

  def self.fetch(type = nil)
    @@store.fetch(type.downcase, 0)
  end

  def self.rt
    [fetch(:roundtime) - Time.now.to_f + offset + 0.6, 0].max
  end

  def self.castrt
    [fetch(:casttime) - Time.now.to_f + offset + 0.6, 0].max
  end

  def self.castrt?
    castrt > 0
  end

  def self.rt?
    rt > 0
  end

  def self.cast_rt!
    @@lock.synchronize do
      sleep castrt while castrt?
    end
  end

  def self.hard_rt!
    @@lock.synchronize do
      sleep rt while rt?
    end
  end
end
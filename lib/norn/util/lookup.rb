class Lookup
  attr_reader :name, :entries, :lock

  def initialize(name)
    @name    = name.to_sym
    @lock   = Mutex.new
    self.clear
  end

  def keys
    @lock.synchronize do
      @entries.keys
    end
  end

  def clear
    @entries = Hash.new
  end

  def push(key, val)
    @lock.synchronize do
      members = @entries.fetch(key, [])
      members << val
      @entries[key] = members
      :ok
    end
  end

  def fetch(key, default = [])
    @lock.synchronize do
      @entries.fetch(key, default)
    end
  end
end
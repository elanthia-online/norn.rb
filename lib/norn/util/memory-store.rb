class MemoryStore
  attr_reader :name
  
  def initialize(name = self.class.name, initial = Hash.new)
    unless initial.is_a?(Hash)
      raise Exception.new %{
        cannot create a memory store without Hash
        was : #{initial.class.name}"
      }
    end
    @name  = name.to_sym
    @store = initial
    @lock  = Mutex.new
  end

  def access()
    @lock.synchronize do
      yield @store
    end
  end

  def put(key, val)
    access do
      @store[key.to_sym] = val
    end
    self
  end

  def merge(other)
    access do
      @store = @store.merge(other)
    end
    self
  end

  def each
    access do |store|
      @store.keys.each do |k|
        yield k, @store[k], @store
      end
    end
  end

  def values
    vals = []
    access do |store|
      vals = store.values
    end
    vals
  end

  def keys
    keys = []
    access do |store|
      keys = store.keys
    end
    keys
  end

  def delete(key)
    access do
      @store.delete(key.to_sym)
    end
    self
  end

  def clear
    access(&:clear)
  end

  def fetch(key=nil, default=nil)
    initial = default
    access do
      if key.nil?
        initial = @store
      else
        initial = @store[key.to_sym].nil? ? default : @store[key.to_sym]
      end
    end
    initial
  end

  def to_s
    "<Store:#{@name}:#{fetch}>"
  end
end
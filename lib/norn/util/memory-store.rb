class MemoryStore
  attr_reader :name
  
  def initialize(name = :anonymous, value = Hash.new)
    unless value.is_a?(Hash)
      raise Exception.new "cannot create a memory store without a Hash\nwas : #{value.class.name}"
    end
    @name  = name.to_sym
    @store = value
    @lock  = Mutex.new
  end

  def put(key, val)
    @lock.synchronize do
      @store[key.to_sym] = val
    end
    self
  end

  def each
    @lock.synchronize do
      @store.keys.each do |k|
        yield k, @store[k], @store
      end
    end
  end

  def delete(key)
    @lock.synchronize do
      @store.delete(key.to_sym)
    end
    self
  end

  def fetch(key=nil, default=nil)
    value = default
    @lock.synchronize do
      if key.nil?
        value = @store
      else
        value = @store[key.to_sym].nil? ? default : @store[key.to_sym]
      end
    end
    value
  end

  def to_s
    "<Store:#{@name}:#{fetch}>"
  end
end
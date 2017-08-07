class Buffer
  attr_reader :name
  
  def initialize(name = :anonymous)
    @name = name
    @lock = Mutex.new
    @data = []
  end

  def push(data)
    @lock.synchronize do
      @data << data
    end
    self
  end

  def size
    size = 0
    @lock.synchronize do
      size = @data.size
    end
    size
  end

  def empty?
    size == 0
  end

  def peek
    val = []
    @lock.synchronize do
      val = @data + val
    end
    val
  end

  def flush
    val = []
    @lock.synchronize do
      val = @data + val
      @data = []
    end
    val
  end
end
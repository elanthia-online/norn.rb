class Registry
  attr_reader :members
  def initialize(*members)
    @members = members
    @maps    = Hash.new
    @list    = Array.new
    @lock    = Mutex.new
    @members.each do |prop|
      @maps[prop.to_sym] = Hash.new
    end
  end

  def clear
    @lock.synchronize do
      clear!
    end
    self
  end
  
  def put(*objs)
    @lock.synchronize do
      clear!
      @list = objs
      @maps.each do |prop, store|
        objs.each do |obj|
          val = obj.send(prop)
          store[val] = obj
        end
      end
    end
    self
  end

  def fetch(prop = nil, by = nil, &block)
    val = nil
    @lock.synchronize do
      if prop.nil? && by.nil?
        val = @list.clone
      else
        prop = prop.to_sym
        val = @maps
          .fetch(prop)
          .fetch(by, val)
        unless block.nil?
          val = yield val
        end
      end
    end
    val
  end

  private
  def clear!
    @maps.values.each(&:clear)
  end
end
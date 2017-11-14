class Registry
  def self.for_game_objs
    new(:id, :noun, :name)
  end

  attr_reader :props, :list

  def initialize(*props)
    @props = props
    @maps  = Hash.new
    @list  = Array.new
    @lock  = Mutex.new
    @props.each do |prop|
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
      @list = objs.dup
      @maps.each do |prop, store|
        objs.each do |obj|
          if obj.respond_to?(prop)
            val = obj.send(prop) 
            store[val] = obj
          end
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
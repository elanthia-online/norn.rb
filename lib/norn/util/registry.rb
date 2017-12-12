class Registry
  DEFAULTS = [:id, :noun, :name]

  attr_reader :props, :list

  def initialize(props = DEFAULTS)
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

  def find(**attrs, &block)
    @lock.synchronize do
      return @list.find do |member|
        attrs.take_while do |param, val|
          if member.respond_to?(param)
            member.send(param) == val
          else
            member[param] == val
          end
        end.size.eql?(attrs.size)
      end
    end
  end

  def find(**attrs, &block)
    @lock.synchronize do
      return @list.select do |member|
        attrs.take_while do |param, val|
          if member.respond_to?(param)
            member.send(param) == val
          else
            member[param] == val
          end
        end.size.eql?(attrs.size)
      end
    end
  end

  private
  def clear!
    @maps.values.each(&:clear)
  end
end
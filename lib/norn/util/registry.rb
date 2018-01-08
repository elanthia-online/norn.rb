class Registry
  include Enumerable

  def self._query(member, attrs)
    attrs.take_while do |param, expected|
      actual = if member.respond_to?(param)
        member.send(param)
      elsif member.respond_to?(:[])
        member[param]
      end

      if expected.is_a?(Regexp)
        actual =~ expected
      elsif expected.is_a?(Symbol)
        actual.to_sym.eql?(expected)
      elsif expected.is_a?(Fixnum)
        actual.to_i.eql?(expected)
      else
        actual.eql?(expected)
      end
    end.size.eql?(attrs.size)
  end

  DEFAULTS = [:id, :noun, :name]

  attr_reader :props, :list, :maps

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
  
  def put(*objs, flush: true)
    @lock.synchronize do
      clear! if flush
      @list = objs.dup
      @maps.each do |prop, store|
        objs.each do |obj|
          val = if obj.respond_to?(prop)
            obj.send(prop) 
          elsif obj.respond_to?(:[])
            obj[prop]
          end
          store[val] = obj if val
        end
      end
    end
    self
  end

  def one(**attrs)
    find do |member|
      Registry._query(member, attrs)
    end
  end

  def where(**attrs)
    select do |member|
      Registry._query(member, attrs)
    end
  end

  def each(&block)
    @lock.synchronize do
      @list.each(&block)
    end
  end

  def to_json(opts = {})
    map(&:to_json)
  end

  private
  def clear!
    @maps.values.clear
    @list.clear
  end
end
module Exist
  REQUIRED = {required: true, freeze: true}
  LIST     = {default: Array}
  def self.extended(klass)
    ## create the list of variables
    ## for the constructor
    klass.class_variable_set(:@@props, [])
    klass.extend(ClassMethods)
    klass.include(InstanceMethods)
    ## these props are needed by every Exist
    klass.class_eval do
      prop(:id,   **REQUIRED)
      prop(:noun, **REQUIRED)
      prop(:name, **REQUIRED)
      prop(:tags, **LIST)
    end
  end
  ##
  ## define the class extensions that a Exist
  ## will be extended with
  ##
  module ClassMethods
    def schema(&block)
      class_eval &block
    end

    def prop(name, **opts)
      name = name.to_sym
      
      opts[:default] = opts.fetch(:default, nil)
  
      props << [name, opts]
      
      define_method name do
        instance_variable_get("@#{name}")
      end
  
      define_method "#{name}?" do
        not send(:name).nil?
      end
    end
  
    def props
      class_variable_get(:@@props)
    end
  end
  ##
  ## defines the instance methods that
  ## all Exists share
  ##
  module InstanceMethods
    ##
    ## initializes a Exist subclass
    ##
    def initialize(**vals)
      ## iterate over the white-list of defined props
      ## adding them to the instance
      self.class.props.each do |prop, opts|
        ## fetch the passed value or get the default
        val = vals.fetch(prop, 
          opts[:default])
        ## if the default is a Class then
        ## instantiate it
        val = val.new if val.respond_to?(:new)
        ## should we freeze this field?
        val = val.freeze if opts.freeze
        ## if it was required but is nil then throw
        raise Exception.new "#{prop} is required" if opts.fetch(:required, false) and val.nil?
        ## set the instance variable
        unsafe_write(prop, val)
      end
      freeze
    end

    def unsafe_write(prop, val)
      instance_variable_set("@#{prop}", val)
    end
    ##
    ## a reference to the Game readable id
    ##
    def gid
      "##{id}"
    end
    ##
    ## try to manipulate a Exist in an unsafe way
    ##
    def try(method = nil, &block)
      Try.new do
        if method && self.respond_to?(method)
          self.send(method)
        elsif block
          self.instance_eval(&block)
        else
          nil
        end
      end.result
    end
    ##
    ## make inspection of Exists easier
    ##
    def inspect
      %{<#{self.class.name} #{self.class.props.reduce([]) do |s, d| 
        s << [d.first, send(d.first).inspect].join("=")
      end.join(" ")}>}
    end
    alias_method :to_s, :inspect
    ##
    ## cast a Exist to a Hash
    ##
    def to_h
      return props.reduce(Hash.new) do |h, d|
        h[d.first] = send(d.first)
        h
      end
    end
    ##
    ## create a JSON serializable obj
    ##
    def to_json(opts = {})
      to_h.to_json
    end
    ##
    ## cast a Exist to another Class
    ##
    def as(klass)
      klass.new **to_h
    end

    def props
      self.class.props
    end

    def with(**updates)
      self.class.new **(props.reduce(Hash.new) do |memo, d|
        memo[d.first] = updates.fetch(d.first,
          send(d.first))
        memo
      end)
    end
  end
end
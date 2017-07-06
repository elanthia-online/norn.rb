class Symbol
  def is_boolean_method?
    self.to_s.end_with?("?")
  end

  def from_boolean_method
    self.to_s.from_boolean_method
  end

  def to_boolean_method
    self.to_s.to_boolean_method
  end
end

class String
  def is_boolean_method?
    self.end_with?("?")
  end

  def from_boolean_method
    self[0..-2].to_sym
  end

  def to_boolean_method
    self.is_boolean_method? ? self : self.downcase.concat("?").to_sym
  end
end

class Status
  INDICATOR = /<indicator\s*id='Icon(?<kind>.*?)'\s*visible='(?<state>.*)'\s*\/>/
  Y         = "y"
  N         = "n"
  EFFECTS   = {}

  def self.cast(visible)
    visible == Y ? true : false   
  end

  def self.update(str)
    if result = INDICATOR.match(str)
      EFFECTS[result[:kind].downcase.to_sym] = cast(result[:state])
    end
    self
  end

  def self.method_missing(name)
    if name.is_boolean_method?
      EFFECTS[name.from_boolean_method] || false
    else
      super
    end
  end

  def self.respond_to_missing?(method_name, include_private = false)
    method_name.is_boolean_method? || super
  end
end
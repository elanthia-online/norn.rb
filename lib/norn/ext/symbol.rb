class Symbol
  def is_boolean_method?
    to_s.end_with?("?")
  end

  def from_boolean_method
    to_s.from_boolean_method
  end

  def to_boolean_method
    to_s.to_boolean_method
  end

  def noop?
    self == :noop
  end

  def err?
    self == :err
  end

  def ok?
    self == :ok
  end

  def is_i?
    to_s.is_i?
  end
end
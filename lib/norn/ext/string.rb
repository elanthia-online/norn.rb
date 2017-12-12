class String
  def is_boolean_method?
    end_with?("?")
  end

  def from_boolean_method
    self[0..-2].to_sym
  end

  def to_boolean_method
    is_boolean_method? ? self : downcase.concat("?").to_sym
  end

  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end

  def without_line_breaks
    self.gsub(/\r/," ")
        .gsub(/\n/," ")
  end

  def words
    self.split(" ")
  end

  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end
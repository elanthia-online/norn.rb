class NilClass
  def strip
    self
  end

  def is_i?
    false
  end

  def downcase
    self
  end
end
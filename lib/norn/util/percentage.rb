##
## unified interface for extending
## MemoryStore with percent information
##
module Percentage
  def percent
    current_max = max.to_f
    return 0 if current_max.eql?(0)
    return ((remaining / current_max) * 100).round(0)
  end

  def remaining
    fetch(:remaining, 0)
  end

  def max
    fetch(:max, 100)
  end

  def gt?(val)
    percent > val
  end

  def lt?(val)
    percent < val
  end

  def eql?(val)
    percent.eql?(val)
  end
  ##
  ## mana/encumb & a few other systems can be > 100
  ##
  def max?
    percent >= 100
  end
end
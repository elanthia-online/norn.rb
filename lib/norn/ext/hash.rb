require "ostruct"

class Hash
  def to_struct
    OpenStruct.new self
  end

  def symbolize
    Hash[self.map do |(k,v)| 
      [k.to_sym, v] 
    end]
  end
end
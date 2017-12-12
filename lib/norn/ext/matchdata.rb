require "ostruct"

class MatchData
  def to_struct
    OpenStruct.new to_hash
  end

  def to_hash
    return Hash.new if captures.nil?
    return Hash.new if names.nil?
    Hash[names.map(&:to_sym).zip(captures.map(&:strip).map do |capture|  
      if capture.is_i? then capture.to_i else capture end
    end)]
  end
end
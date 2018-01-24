class Array
  ##
  ## naive implementation of dumping 
  ## an Array of Hashes to String table 
  ##
  def to_table(ljust: [], headers: false)
    width = self.inject(Hash.new(0)) do |col_width, h|
      h.each do |k, v| 
        col_width[k] = [col_width[k], v.to_s.length].max
      end
      col_width
    end
    # todo: add headers
    self.map do |row|
      row.map do |col_name, val|
        alignment = case col_name; 
        when ljust.include?(col_name.to_sym); :ljust 
        else :rjust end
        val.to_s.send(alignment, width[col_name])
      end.join("   ") 
    end.join("\n")
  end
end

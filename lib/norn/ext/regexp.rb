class Regexp
  def scan(s)
    start_at = 0
    matches  = []
    while(m = s.match(self, start_at))
      matches.push(m)
      start_at = m.end(0)
    end
    matches
  end
end
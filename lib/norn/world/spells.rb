class Spells
  def self.parse(tag)
    [tag.fetch(:anchor_right), 
      *tag.fetch(:value).strip.split(":").map(&:to_i)]
  end

  attr_reader :active, :known

  def initialize()
    @active   = Hash.new
    @known    = Hash.new
    @prepared = nil
  end

  def prepare(spell)
    @prepared = spell
  end

  def learn(num, spell)
    @known[num] = spell
  end

  def add(name, hours, minutes)
    @active[name] = (hours * 60 * 60) + minutes * 60
  end

  def flush!()
    @active.clear
  end
end
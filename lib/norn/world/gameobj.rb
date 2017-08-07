require "norn/parser/parser"

class Array
  def to_game_objs
    self.map do |data|
      GameObj.new *data
    end
  end
end

class GameObj < Struct.new(:id, :noun, :name, :status, :tags)
  def self.parse(str)
    str  = Norn::Parser.strip_xml(str, Norn::Parser::Tags::Bold)
    
    objs = str.scan(Norn::Parser::Tags::Exist).to_game_objs

    byId = objs.reduce(Hash.new) do |map, obj|
      map[obj.id] = obj
      map
    end

    Status.parse(str).each do |id, name, desc, status|
      byId[id].status = status.split(", ").map(&:to_sym)  
    end

    objs
  end

  def initialize(id, noun, name, status = [], tags = [])
    super(id, noun, name, status, tags)
  end

  def tag(*tags)
    tags = tags + tags.map(&:to_sym)
  end

  def to_game
    %{##{id}}
  end

  def inspect
    to_s
  end

  def to_player
    Player.new(id, noun, name, status, tags)
  end
end
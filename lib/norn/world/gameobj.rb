require "norn/parser/parser"

class Array
  def to_game_objs
    self.map do |data|
      GameObj.new *data
    end
  end
end

class GameObj < Struct.new(:id, :noun, :name, :status, :after_name, :tags)
  VERBOSE_EFFECT = "that is"
  BRIEF_EFFECT   = "("

  def self.parse(tags)
    tags.map do |tag|
      tail = tag.fetch(:tail)
      after_name = nil
      status = if tail.nil?
        []
      elsif tail[0] == BRIEF_EFFECT
        tail[1..-2].split(", ")
      elsif tail.start_with?(VERBOSE_EFFECT)
        tail[VERBOSE_EFFECT.size..-1].split(", ").map(&:strip)
      else
        after_name = tail
        []
      end

      new(
        tag.fetch(:exist),
        tag.fetch(:noun),
        tag.text,
        status.map(&:to_sym),
        after_name,
      )
    end
  end

  def initialize(id, noun, name, status = [], after_name = nil, tags = [])
    super(id, noun, name, status, after_name, tags)
  end

  def tag(*tags)
    tags = tags + tags.map(&:to_sym)
  end

  def to_game
    %{##{id}}
  end

  def full_name
    (name + " " + (after_name || "")).strip
  end

  def inspect
    to_s
  end
end
require "ostruct"

module Generator
  module Hand
    TYPES = [
      :left,
      :right,
    ]

    def self.full(type, id, noun, desc)
      OpenStruct.new(
        empty: false,
        type: type,
        string: %{<#{type} exist="#{id}" noun="#{noun}">#{desc}</#{type}>},
      )
    end

    def self.empty(type, id, noun, desc)
      OpenStruct.new(
        empty: true,
        type: type,
        string: %{<#{type}>Empty</#{type}>}
      )
    end

    def self.generate
      id     = Integer.random(-10_000, 10_000)
      noun   = String.random(3)
      desc   = [String.random, String.random, noun].join(" ")
      type   = TYPES.sample.to_s
      method = [:full, :empty].sample
      send(method, 
        type, id, noun, desc)
    end

    def self.random_list(min = 1, max = 20)
      size = Integer.random(min, max)
      list = Array.new(size) do generate end
      OpenStruct.new(
        size:   size,
        list:   list,
        string: list.join(", a "),
      )
    end
  end
end
module Generator
  module Exist
    def self.generate
      id     = Integer.random(-10_000, 10_000)
      noun   = String.random(3)
      desc   = [String.random, String.random, noun].join(" ")
      %{<a exist="#{id}" noun="#{noun}">#{desc}</a>}
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
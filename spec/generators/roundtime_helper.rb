module Generator
  module Roundtime
    TYPES = [
      :castTime,
      :roundTime,
    ]
    def self.generate
      type = TYPES.sample
      duration = Time.now.to_i + Integer.random(1, 30)
      OpenStruct.new(
        type: type,
        duration: duration,
        string: %{<#{type} value="#{duration}"/>},
      )
    end
  end
end
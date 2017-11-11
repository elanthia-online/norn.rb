require "norn/util/memory-store"
require "norn/util/percentage"

class Mind < MemoryStore
  include Percentage

  MAPPINGS = {
    saturated:       "saturated",
    must_rest:       "must rest",
    numbed:          "numbed",
    becoming_numbed: "becoming numbed",
    muddled:         "muddled",
    clear:           "clear",
    fresh_and_clear: "fresh and clear",
    clear_as_a_bell: "clear as a bell",
  }

  INVERSE_MAPPINGS = MAPPINGS.invert

  def self.decode(text)
    INVERSE_MAPPINGS.fetch(text.strip)
  end

  def current
    fetch(:current, nil)
  end

  MAPPINGS.each do |method, text|
    send(:define_method, method.to_boolean_method) do
      current.eql?(text)
    end
  end
end
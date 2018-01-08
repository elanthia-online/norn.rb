require "norn/gameobj/gameobj"
module Norn
  class Monster
    extend GameObj
    prop :status, default: Array
    prop :level
    prop :skin

    def initialize(**vals)
      super **vals.merge(Metadata.creatures.fetch(vals[:name].downcase, {}))
    end
  end
end
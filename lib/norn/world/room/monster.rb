require "norn/exists/exist"
module Norn
  class Monster
    extend Exist
    prop :status, default: Array
    prop :level
    prop :skin

    def initialize(**vals)
      super **vals.merge(Metadata.creatures.fetch(vals[:name].downcase, {}))
    end
  end
end
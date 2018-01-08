require "norn/gameobj/gameobj"
module Norn
  class Player
    extend GameObj
    prop :status, default: Array
  end
end
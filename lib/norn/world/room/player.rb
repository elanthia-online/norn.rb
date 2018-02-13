require "norn/exist/exist"
module Norn
  class Player
    extend Exist
    prop :status, default: Array
  end
end
# encoding: US-ASCII
require "norn/version"
require "norn/parser"
require "norn/game"
require "norn/handshake"
require "norn/world/status"

module Norn
  ##
  ## the global norn scripting command regex
  ##
  COMMAND     = /^(\/|;)/
  ##
  ## dot commands to interact with a Norninstance
  ##
  DOT_COMMAND = /^\./
  ##
  ## @brief      generates a non-blocking connection to a game
  ##
  ## @param      args  The arguments
  ##
  def self.connect(*args)
    Handshake.connect *args
  end
  ##
  ## @brief      convenience method to grab the current
  ##             game instance
  ##           
  ## @return     Norn::Game
  ##
  def self.game
    Norn::Game.instance
  end
end

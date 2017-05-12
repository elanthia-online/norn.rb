# encoding: US-ASCII
require "norn/version"
require "norn/parser"
require "norn/game"
require "norn/handshake"

module Norn
  ##
  ## the global norn scripting command regex
  ##
  COMMAND = /^(\/|;)/
  ##
  ## @brief      generates a non-blocking connection to a game
  ##
  ## @param      args  The arguments
  ##
  ## @return     Thread
  ##
  def self.connect(*args)
    Thread.new do
      Handshake.connect *args
    end
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

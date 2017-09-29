# encoding: US-ASCII
require "cgi"
require "norn/version"
Dir[File.dirname(__FILE__) + '/norn/ext/**/*.rb'].each do |file| require file end
Dir[File.dirname(__FILE__) + '/norn/**/*.rb'].each do |file| require file end

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
  def self.connect(port = Norn::Game::PORT, *args)
    Handshake.connect port, *args
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

  DEBUG = ENV.fetch("DEBUG", false)
  DEBUG_PATTERN = %r{#{DEBUG}}

  def self.log(message, label = :debug)
    
    return self unless DEBUG

    return self unless label.to_s.match(DEBUG_PATTERN)

    if message.is_a?(Exception)
      message = [
        message.message,
        message.backtrace.join("\n"),
      ].join
    end
    puts "[Norn.#{label}] #{message}"
  end
end

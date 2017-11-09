# encoding: US-ASCII
Dir[File.dirname(__FILE__) + '/norn/ext/**/*.rb'].each do |file| require file end
Dir[File.dirname(__FILE__) + '/norn/**/*.rb'].each do |file| require file end
##
## a scripting layer for Gemstone IV
##
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
  
  DEBUG = ENV.fetch("DEBUG", false)
  DEBUG_PATTERN = %r{#{DEBUG}}
  GLOBAL_LOCK = Mutex.new

  def self.log(message, label = :debug)
    GLOBAL_LOCK.synchronize do
      return self unless DEBUG
      return self unless label.to_s.match(DEBUG_PATTERN)
      if message.is_a?(Exception)
        message = [
          message.message,
          message.backtrace.join("\n"),
        ].join
      end
      puts "[Norn.#{label}] #{message.inspect}"
    end
  end

  def self.clobber(patt)
    $LOADED_FEATURES
      .select do |path| path =~ /#{patt}/ && path.end_with?(".rb") end
      .each do |old| load(old) end
  end
end

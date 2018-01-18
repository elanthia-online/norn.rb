class Script
  ##
  ## provides the ability for a Script
  ## to register a set of commands
  ## without requiring a bunch of parsing
  ##
  class Commands
    attr_reader :entries
    def initialize()
      @entries = Hash.new
    end

    def add(command, &block)
      @entries[command.to_sym] = block
    end

    def run(command, *args)
      @entries.fetch(command.to_sym).call(*args)
    end

    def has?(command)
      @entries.key?(command)
    end
  end
end

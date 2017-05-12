require "observer"

module Norn
  class Parser
    include Observable
    QUEUE  = Queue.new
    PARSER = Parser.new
    WORKER = Thread.new do PARSER.link! end

    class Subscriber
      def initialize
        Parser.add_observer(self)
      end
    end

    def self.add_observer(thing)
      PARSER.add_observer(thing)
    end

    def self.<<(raw)
      QUEUE << raw
      self
    end

    def link!
      loop do
        run!
        sleep 0.1
      end
    end

    def run!
      # TODO: try? wrapper would be ideal here
      parse(QUEUE.shift) unless QUEUE.empty?
    end

    def parse(str)
      #puts "Parser.parse(#{str})"
    end

    def notify(parsed)
      changed
      notify_observers(parsed)
    end
  end
end
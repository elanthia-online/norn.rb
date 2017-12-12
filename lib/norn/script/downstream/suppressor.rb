class Script
  module Downstream
    class Suppressor
      def self.of(**args)
        new **args
      end

      attr_reader :start, :done, :started, :mutator

      def initialize(mutator, start: nil, done: %r{^<prompt})
        # has it begun receiving data?
        @started = false  
        # pattern to signal receiving data
        @start   = start
        # pattern to signal stop receiving data
        @done    = done
        this     = self
        @mutator = mutator.of do |line|
          this.handle(line)
        end
      end

      def started?
        @started
      end

      def await
        sleep 0.1 while @mutator.alive?
        self
      end

      def start!
        @started = true
      end

      def running?
        @mutator.alive?
      end

      def handle(line)
        return nil if line.nil?
        @mutator.teardown if line.match(@done)
        start! if line.match(@start)
        return line unless started?
        return nil
      end
    end
  end
end
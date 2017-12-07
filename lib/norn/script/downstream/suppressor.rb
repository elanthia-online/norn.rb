class Script
  module Downstream
    class Suppressor
      def self.of(**args)
        new **args
      end

      attr_reader :start, :done, :active, :ran

      def initialize(mutator, start: nil, done: %r{^<prompt})
        @active = false
        @start  = start
        @ran    = false
        @done   = done
        this    = self
        mutator.of do |line|
          this.handle(line)
        end
      end

      def ran?
        @ran
      end

      def on!
        @ran    = true
        @active = true
      end

      def off!
        @active = false
      end

      def on?
        @active
      end

      def handle(line)
        off! if line.match(@done)
        on!  if line.match(@start)
        return nil if on?
        return line
      end
    end
  end
end
class Script
  module Downstream
    class Mutator < Thread
      attr_reader :supervisor, 
                  :callback, :registry
      
      def initialize(registry, supervisor, &callback)
        ## the supervisor thread
        @supervisor = supervisor
        ## add our IO callback
        @callback   = callback
        @registry   = registry
        ## alias self since the context
        ## will change inside of super
        ## add it to the registry
        registry.push(self)
        super do
          sleep(0.1) while self.supervisor.alive?
          self.teardown
        end
      end

      def teardown
        registry.delete(self)
        kill
      end

      def call(data)
        mutator = self
        work = Try.new do
          mutator.callback.call(data)
        end
        Try.dump(mutator.supervisor, work)
        if work.failed?
          return :err
        else
          return work.result
        end
      end
    end
  end
end
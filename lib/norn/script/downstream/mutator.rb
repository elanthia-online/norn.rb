class Script
  module Downstream
    class Mutator < Thread
      attr_reader :supervisor, 
                  :callback
      
      def initialize(registry, supervisor, &callback)
        ## the supervisor thread
        @supervisor = supervisor
        ## add our IO callback
        @callback   = callback
        ## alias self since the context
        ## will change inside of super
        mutator     = self
        ## add it to the registry
        registry.push(mutator)
        super do
          sleep(0.1) while mutator.supervisor.alive?
          registry.delete(mutator)
        end
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
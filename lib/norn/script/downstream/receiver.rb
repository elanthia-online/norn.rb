class Script
  module Downstream
    class Receiver < Thread
      attr_reader :queue,
                  :supervisor,
                  :callback,
                  :registry
      
      def initialize(registry, supervisor, &callback)
        return unless supervisor.is_a?(Thread)
        ## the supervisor thread
        @supervisor = supervisor
        @registry   = registry
        ## the queue
        @queue      = Queue.new
        ## add our IO callback
        @callback   = callback
        ## alias self since the context
        ## will change inside of super
        receiver    = self
        ## add it to the registry
        receiver.registry.push(receiver)
        super do
          while receiver.supervisor.alive? and receiver.alive?
            begin
              if receiver.queue.empty?
                sleep 0.1
              else
                receiver.callback.call(receiver.queue.shift)
              end
            rescue => exception
              Try.dump(receiver.supervisor, exception)
              System.log(exception, label: %i{downstream error})
            end
          end
          receiver.registry.delete(receiver)
          receiver.kill if alive?
        end
      end

      def closed?
        not alive?
      end
      ##
      ## write to the underlying receiving IO 
      ##
      def puts(incoming)
        @queue.push incoming
        System.log(incoming, label: %i{receiver puts})
      end
    end
  end
end
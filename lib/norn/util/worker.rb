require "norn/util/try"

module Norn
  def self.workers
    Norn::Worker::WORKERS.list
  end

  class Worker < Thread
    WORKERS = ThreadGroup.new
    TICK    = 0.1
    @@uuid  = -1

    def self.uuid
      @@uuid = @@uuid + 1
      @@uuid
    end
    ##
    ## workers should never silence errors
    ## because they are useful for debugging
    ## asynchronous operations
    ##
    def self.log(message, label = :debug)
      if message.is_a?(Exception)
        message = [
          message.message,
          message.backtrace.join("\n"),
        ].join
      end
      puts "[Norn.Worker.#{label}] #{message.inspect}"
    end

    attr_accessor :name, :state
    def initialize(name = Worker.uuid)
      @name  = name
      @state = :up
      worker = self
      super do
        loop do
          work = Try.new do
            yield(worker)
          end

          if work.failed?
            Worker.log work.result, :error
            Worker.log work.result.backtrace.join("\n"), :error
          end
          
          break if @state.eql?(:shutdown)
          sleep TICK
        end
      end
      WORKERS.add self
    end

    def shutdown
      @state = :down
    end
  end
end
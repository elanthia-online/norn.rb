require "norn/util/try"

module Norn
  WORKERS = ThreadGroup.new
  TICK    = 0.1
  
  def self.workers
    WORKERS.list
  end

  class Worker < Thread
    @@uuid = -1

    def self.uuid
      @@uuid = @@uuid + 1
      @@uuid
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
            Norn.log work.result, :error
            Norn.log work.result.backtrace.join("\n"), :error
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
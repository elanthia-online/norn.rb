require "norn/util/try"

module Norn
  WORKERS = ThreadGroup.new
  
  def self.workers
    WORKERS.list
  end

  class Worker < Thread
    @@uuid = -1

    def self.uuid
      @@uuid = @@uuid + 1
      @@uuid
    end

    attr_accessor :name
    def initialize(name = Worker.uuid)
      @name = name
      super do
        loop do
          work = Try.new do
            yield
          end

          if work.failed?
            Norn.log work.result, :error
            Norn.log work.result.backtrace.join("\n"), :error
          end

          sleep 0.1
        end
      end
      WORKERS.add self
    end
  end
end
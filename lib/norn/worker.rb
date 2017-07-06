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
          yield
          sleep 0.1
        end
      end
      WORKERS.add self
    end
  end
end
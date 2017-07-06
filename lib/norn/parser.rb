require "norn/worker"
require "norn/world/status"

module Norn
  module Parser
    POOL_SIZE = 4
    QUEUE     = Queue.new

    POOL  = Array.new(POOL_SIZE) do
      Worker.new do
        Parser.parse(Parser::QUEUE.shift) unless Parser::QUEUE.empty?
      end
    end

    SUPERVISOR = Worker.new(:parser_pool_supervisor) do      
      POOL.each do |worker|
        unless worker.alive?
          POOL.delete(worker)
          POOL << Worker.new
        end
      end
    end

    def self.<<(raw)
      QUEUE << raw
      self
    end

    def self.parse(incoming)
      puts(incoming)
      Status.update(incoming)
    end
  end
end
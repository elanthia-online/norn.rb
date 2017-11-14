class Script
  class Downstream < Thread
    LIST = []
    attr_reader :game, :read, :write, :script, :thread
    
    def initialize(game, script, &block)
      @game   = game   
      @script = script
      @read, @write = IO.pipe
      Norn.log(self, :downstream)
      hook = self
      @game.clients << @write
      LIST << self
      super do
        begin
          while !@read.closed? && @script.alive? && line = @read.gets
            block.call(line.dup)
          end
          hook.close
        rescue => exception
          Norn.log(exception, :downstream)
          hook.close
        end
      end
    end

    def close
      @read.close
      @write.close
      @game.clients.delete(@write)
      LIST.delete(self)
    end
  end
end
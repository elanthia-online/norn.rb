require "norn/util/try"
require "norn/script/script"

class Script
  class Context
    def self.of(script)
      ctx = Class.new(Context) do
        # TODO
      end
      ctx.const_set :World,  script.game.world 
      ctx.const_set :Room,   script.game.world.room
      ctx.const_set :Status, script.game.world.status
      ctx
    end
  end

  class Exec
    COMMAND = /^\/(?<mode>e|i)/
    @@id    = 0
    INTERACTIVE = "i"

    def self.next_id
      @@id = @@id + 1
      @@id
    end

    private_class_method :next_id

    def self.run(game, herescript)
      begin
        mode = herescript.match(COMMAND)[:mode] == INTERACTIVE ? :silent : :normal
        Script.new(game, "exec:#{next_id}", mode: mode) do |script|
          script.result = Context.of(script).class_eval(herescript.gsub(COMMAND, "").strip)
          if herescript.match(COMMAND)[:mode] == INTERACTIVE
            script.write script.result.to_s
          end
          script.result
        end
      rescue => exception
        game.write_to_clients(e.message)
        game.write_to_clients(e.backtrace.join("\n"))
      end
    end
  end
end
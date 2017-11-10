require "norn/util/try"
require "norn/script/script"
require "norn/script/context"

class Script
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
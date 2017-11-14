require "norn/util/try"
require "norn/script/script"
require "norn/script/context"

class Script
  class Exec
    @@id        = 0

    def self.next_id
      @@id = @@id + 1
      @@id
    end

    private_class_method :next_id

    def self.run(game, herescript, **opts)
      begin
        Script.new(game, "exec:#{next_id}", mode: :silent) do |script|
          script.result = Context.of(script).class_eval(herescript.strip)
          script.write(script.result.to_s) unless opts.fetch(:mode, :silent).eql?(:silent)
          script.result
        end
      rescue => err
        game.write_to_clients(err.message)
        game.write_to_clients(err.backtrace.join("\n"))
      end
    end
  end
end
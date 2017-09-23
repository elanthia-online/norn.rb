require "norn/util/try"
require "norn/script/script"

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

    def self.run(herescript)
      mode = herescript.match(COMMAND)[:mode] == INTERACTIVE ? :silent : :normal
      Script.new("exec:#{next_id}", mode: mode) do |script|
        script.result = script.instance_eval(herescript.gsub(COMMAND, "").strip)
        if herescript.match(COMMAND)[:mode] == INTERACTIVE
          script.write script.result.to_s
        end
        script.result
      end
    end
  end
end
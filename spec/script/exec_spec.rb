require "norn/world/status"
require "spec_helper"
require "norn/script/exec"

describe Script::Exec do
  describe "#run" do
    it "runs basic Ruby stuffs" do
      expect(Script::Exec.run("/e 2 + 2").await)
        .to eq(4)
    end
    
    it "can safely access Norn objects" do
      Generator.run(Generator::Status, samples: 10) do |status|
        Norn::Parser.parse status.string
        expected = Status.cast(status.visible)
        result   = Script::Exec.run("/e Status.#{status.kind.downcase}?").await
        expect(result)
          .to eq(expected), %{
            tag: #{status}
         result: #{result}
       expected: #{expected}
          }
      end
    end
  end
end
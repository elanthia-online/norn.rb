require "norn/world/status"
require "spec_helper"
require "norn/script/exec"

describe Script::Exec do
  describe "#run" do
    it "runs basic Ruby stuffs" do
      expect(Script::Exec.run("2 + 2").await)
        .to eq(4)
    end
    
    it "can safely access Norn objects" do
      Generator.run(Generator::Status, samples: 10) do |status|
        Status.update status.string
        expected = Status.send(status.kind.to_boolean_method)
        actual   = Status.cast(status.visible)
        result   = Script::Exec.run("Status.#{status.kind.downcase}?").await
        expect(result)
          .to eq(actual)
      end
    end
  end
end
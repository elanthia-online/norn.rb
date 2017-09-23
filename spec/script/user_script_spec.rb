require "norn/world/status"
require "spec_helper"
require "norn/script/user"

describe Script::UserScript do
  describe Script::UserScript::Loader do
    it "runs script" do
      expect(Script::UserScript.run("test").await)
        .to be Hand.left
    end

    it "runs package" do
      expect(Script::UserScript.run("package.test").await)
        .to eq "test.package"
    end
  end
end
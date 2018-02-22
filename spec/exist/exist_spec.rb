require "norn/exist/exist"

class Plane
  extend Exist
  def fly
    "fly #{gid}"
  end
end

describe Exist do
  describe "schema" do
    it "constructs properly" do
      m = Plane.new(
        id:   1,
        noun: "jet",
        name: "boeing 747",
      )
      expect(m).to respond_to(:fly)
    end
  end
end
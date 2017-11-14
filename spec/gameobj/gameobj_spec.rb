require "norn/gameobj/gameobj"

class Plane
  extend GameObj
  def fly
    "fly #{gid}"
  end
end

describe GameObj do
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
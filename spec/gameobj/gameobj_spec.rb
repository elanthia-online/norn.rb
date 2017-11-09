require "norn/gameobj/gameobj"

class Monster 
  extend GameObj

  def kill
    puts "kill #{gid}"
  end
end

describe Monster do
  describe "#new" do
    it "constructs properly" do
      m = Monster.new(
        id:   1,
        noun: "guy",
        name: "bad guy",
      )
      m.kill
    end
  end
end
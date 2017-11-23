require "spec_helper"

describe Script::Downstream::Mutator do
  it "listens to its supervisor thread" do
    registry = []

    supervisor = Thread.new do
      loop do sleep 1 end
    end

    mutator = described_class.new(registry, supervisor) do |incoming|
      incoming.strip
    end

    10.times do
      string = Generator::String.random(1, 20) + "\n"
      result = mutator.call string 
      expect(result.size < string.size)
        .to(be(true), %{
          string : #{string}
          result : #{result}
        })
    end

    supervisor.kill
    
    sleep 0.1 while supervisor.alive? and mutator.alive?


    expect(mutator.alive?)
      .to be false

    expect(registry.empty?)
      .to be true
  end
end
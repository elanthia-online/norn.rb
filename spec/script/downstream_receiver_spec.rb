require "spec_helper"

describe Script::Downstream::Receiver do
  it "listens to its supervisor thread" do
    registry = []

    supervisor = Thread.new do
      loop do sleep 1 end
    end

    received = []
    receiver = described_class.new(registry, supervisor) do |incoming|
      received << incoming.strip
    end

    sent = []
    10.times do
      sent << Generator::String.random(1, 20)
      receiver.puts sent.last
    end

    sleep 0.1 until receiver.queue.empty?
    supervisor.kill
    
    sleep 0.1 while supervisor.alive? and receiver.alive?

    expect(sent)
      .to eq received

    expect(registry.empty?)
      .to be true
  end
end
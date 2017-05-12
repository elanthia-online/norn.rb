# encoding: US-ASCII
require 'socket'
require 'spec_helper'
require 'norn/game'
require 'norn/handshake'

describe Norn::Game do
  before(:each) do
    Norn::Game.clear
  end

  describe '#downstream' do
    it 'accepts multithreaded downstream connections' do
      norn = Norn.connect(
        account:   ENV.fetch("GS_ACCOUNT"),
        password:  ENV.fetch("GS_PASSWORD"),
        game:      ENV.fetch("GS_GAME"),
        character: ENV.fetch("GS_CHARACTER"),
      )

      client1 = Thread.new do
        socket = Norn::Game.downstream
        line   = nil
        break while line = socket.gets
      end

      client2 = Thread.new do
        socket = Norn::Game.downstream
        line   = nil
        break while line = socket.gets
      end

      line1 = client1.value
      line2 = client2.value

      expect(line1).to be line2
    end
  end
end

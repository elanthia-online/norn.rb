# encoding: US-ASCII
require 'socket'
require 'spec_helper'

describe Norn::Game do

  describe '#downstream' do
    it 'accepts multithreaded downstream connections' do
      game = Norn.connect(4040,
        account:   ENV.fetch("GS_ACCOUNT"),
        password:  ENV.fetch("GS_PASSWORD"),
        game:      ENV.fetch("GS_GAME"),
        character: ENV.fetch("GS_CHARACTER"),
      )

      client1 = Thread.new do
        socket = game.downstream
        line   = nil
        break while line = socket.gets
        line
      end

      client2 = Thread.new do
        socket = game.downstream
        line   = nil
        break while line = socket.gets
        line
      end

      expect(client1.value).to be_truthy
      expect(client1.value).to eq client2.value
    end
  end
end

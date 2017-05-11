# encoding: US-ASCII
require 'spec_helper'
require 'game/game'
require 'handshake/auth'

describe Norn::Game do
  before(:each) do
    Norn::Game.clear
  end

  describe '#on_connect' do
    it "works" do
      Norn::Game.on_connect do |game|
        # noop
      end

      expect(Norn::Game.callbacks.size).to be 1
    end
  end

  describe '#connect' do
    it 'yields a one-time password' do

      Norn::Game.on_connect do |game|
        game.die!
      end

      Norn::Handshake.new(
        account:   ENV.fetch("GS_ACCOUNT"),
        password:  ENV.fetch("GS_PASSWORD"),
        game:      ENV.fetch("GS_GAME"),
        character: ENV.fetch("GS_CHARACTER"),
      ) do |otp| Norn::Game.connect otp end
    end
  end
end

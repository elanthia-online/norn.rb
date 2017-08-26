# encoding: US-ASCII
require 'spec_helper'

describe Norn::Handshake do
  describe '#new' do
    it 'raises on bad passwords' do
      expect do
        Norn::Handshake.new(
          account:   "travis-ci-2",
          password:  "supersecretkeyboardcat",
          game:      "GS3",
          character: "noone",
        )
      end.to raise_error Norn::Handshake::BadPassword
    end

    it 'yields a one-time password' do
      Norn::Handshake.new(
        account:   ENV.fetch("GS_ACCOUNT"),
        password:  ENV.fetch("GS_PASSWORD"),
        game:      ENV.fetch("GS_GAME"),
        character: ENV.fetch("GS_CHARACTER"),
      ) do |otp|
        puts otp
        expect(otp).not_to be_nil
        expect(otp.key).not_to be_nil
      end
    end

    it 'yields a character list' do
      result = Norn::Handshake.new(
        account:   ENV.fetch("GS_ACCOUNT"),
        password:  ENV.fetch("GS_PASSWORD"),
        game:      ENV.fetch("GS_GAME"),
      ) do |characters|
        character = characters.list[ENV.fetch("GS_CHARACTER")]
        expect(character).not_to be_nil
        character
      end
      expect(result.finished?).to be true
    end
  end
end

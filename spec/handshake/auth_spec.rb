# encoding: US-ASCII
require 'spec_helper'
require 'handshake/auth'

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

    it 'fetches one-time password' do
      result = Norn::Handshake.new(
        account:   ENV.fetch("GS_ACCOUNT"),
        password:  ENV.fetch("GS_PASSWORD"),
        game:      ENV.fetch("GS_GAME"),
        character: ENV.fetch("GS_CHARACTER"),
      )
      expect(result.characters.list.keys).to include ENV.fetch("GS_CHARACTER")
      expect(result.otp).not_to be_nil
      expect(result.otp.key).not_to be_nil
    end
  end
end

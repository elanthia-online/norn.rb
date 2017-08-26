require 'spec_helper'

Parser = Norn::Parser
describe Parser::RTDecoder do
  describe '#update' do
    it "updates roundtimes" do
      Generator.run(Generator::Roundtime, samples: 10) do |roundtime|
        Parser.parse(roundtime.string)
        actual = Roundtime.fetch(roundtime.type)
        expect(actual)
          .to eq(roundtime.duration)
        
        bool, current = if roundtime.type == :castTime
          [Roundtime.castrt?, Roundtime.castrt]
        else
          [Roundtime.rt?, Roundtime.rt]
        end

        expect(bool)
          .to be(true)
        
      end
    end
  end
end
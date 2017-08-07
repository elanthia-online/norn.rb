require 'spec_helper'

RTDecoder = Norn::Parser::RTDecoder
describe RTDecoder do
  describe 'Tags::Roundtime' do
    it "matches" do
      Generator.run(Generator::Roundtime) do |roundtime|
        expect(Norn::Parser::Tags::RoundTime.match(roundtime.string))
          .to be_truthy, %{
            string: #{roundtime.string}
          }
      end
    end
  end
  describe '#update' do
    it "updates roundtimes" do
      Generator.run(Generator::Roundtime, samples: 10) do |roundtime|
        RTDecoder.update(roundtime.string)
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
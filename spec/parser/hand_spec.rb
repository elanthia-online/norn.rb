require 'spec_helper'

HandsDecoder = Norn::Parser::HandsDecoder
Tags  = Norn::DSL::Tags
describe HandsDecoder do
  describe 'Hand Tags' do
    it "matches HandOpen" do
      Generator.run(Generator::Hand) do |hand|
        actual = hand.string.match(Tags::HandOpen)
        expect(actual)
          .to be_a(MatchData)
      end
    end

    it "matches HandClose" do
      Generator.run(Generator::Hand) do |hand|
        actual = hand.string.match(Tags::HandClose)
        expect(actual)
          .to be_a(MatchData)
      end
    end
  end

  describe '#update' do
    def test_full_hand(actual, expected)
      expect(actual)
        .to be_a(Hand)
      expect(actual.id.nil?)
        .to eq(false)
      expect(actual.noun.nil?)
        .to eq(false)
      expect(actual.name.nil?)
        .to eq(false)
    end

    def test_empty_hand(actual, expected)
      expect(actual.empty?)
        .to eq(true)
      expect(actual.noun)
        .to eq(:empty)
      expect(actual)
        .to be(Hand::Empty)
    end

    it "updates hands" do
      Generator.run(Generator::Hand) do |hand|
        HandsDecoder.update(hand.string)
        actual = Hand.fetch(hand.type)
        if hand.empty
          test_empty_hand(actual, hand)
        else
          test_full_hand(actual, hand)
        end
      end
    end
  end
end
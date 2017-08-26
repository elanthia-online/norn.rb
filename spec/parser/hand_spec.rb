require 'spec_helper'

Parser      = Norn::Parser

describe Parser::HandDecoder do
  
  def test_empty_hand(actual, expected)
    expect(actual.empty?)
      .to eq(true)
    expect(actual.noun)
      .to eq(:empty)
    expect(actual)
      .to be(Hand::Empty)
  end

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

  describe '#update' do
    
    it "updates hands" do
      Generator.run(Generator::Hand) do |hand|
        Parser.parse(hand.string)
        
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
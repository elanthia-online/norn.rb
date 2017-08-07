require 'spec_helper'

StyleDecoder = Norn::Parser::StyleDecoder
describe StyleDecoder do
  describe 'Tags::Style', focus: true do
    it "matches" do
      Generator.run(Generator::Style) do |style|

        expect(Norn::Parser::Tags::StyleOpen.match(style.string))
          .to be_truthy, %{
            string: #{style.string}
          }
        expect(Norn::Parser::Tags::StyleClose.match(style.string))
          .to be_truthy, %{
            string: #{style.string}
          }
        
        if style.way == :complex
          expect(StyleDecoder.scan(style.string).size)
            .to eq(2)
          
          StyleDecoder.update(style.string)
      
          expect(StyleDecoder.buffer.empty?)
            .to be_truthy

          expect(style.string.include?(Room.desc.text))
            .to be_truthy
          
          expect(style.string.include?(Room.title))
            .to be_truthy
        end
      end
    end
  end
  describe '#update' do
    it "sees chunks" do
      sample = Generator.sample(:style, :room)
      expect(StyleDecoder.scan(sample).size)
        .to eq(2)
    end

    it "clears buffer" do
      sample = Generator.sample(:style, :room)
      StyleDecoder.update(sample)
      expect(StyleDecoder.buffer.empty?)
        .to be_truthy
      
      puts Room.title
      puts Room.desc
    end

    it "updates styles" do
      Generator.run(Generator::Style) do |style|
        StyleDecoder.update(style.string)
        actual = Room.fetch(style.type)
        
      end
    end
  end
end
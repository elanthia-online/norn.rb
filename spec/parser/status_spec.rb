require 'spec_helper'

StatusDecoder = Norn::Parser::StatusDecoder
describe StatusDecoder do
  describe '#cast' do
    it "decodes game boolean types" do
      expect(StatusDecoder.cast("Y").last)
        .to eq(true)
      
      expect(StatusDecoder.cast("N").last)
        .to eq(false)
      
      expect(StatusDecoder.cast("y").last)
        .to eq(StatusDecoder.cast("Y").last)
    end
  end
  describe '#update' do
    it "updates statuses" do
      Generator.run(Generator::Status) do |status|
        StatusDecoder.update(status.string)
        actual   = Status.send(status.kind.to_boolean_method)
        expected = StatusDecoder.cast(status.visible).last
        expect(expected).to eq(actual), %{
             tag : #{status.string}
          status : #{status}
        expected : #{expected}
          actual : #{actual}
        }
      end
    end
  end
end
require 'spec_helper'

ComponentDecoder = Norn::Parser::ComponentDecoder
describe ComponentDecoder do

  describe '#update' do
    it "updates components" do
      Generator.run(Generator::Component) do |component, i|
        chunks = component.chunks.clone
        until chunks.empty?
          ComponentDecoder.update chunks.shift
        end
        actual   = ComponentDecoder.fetch(component.type).size
        expected = component.exists.size
        registry_key = component.type.split(" ").last.to_sym

        actual = Room.send registry_key
            
        expect(actual.size).to eq(expected), %{
          iteration : #{i}
       registry key : #{registry_key}
         Room.fetch : #{Room.fetch}
                tag : #{component.chunks.join}
             actual : #{actual.size}
           expected : #{expected}
        }
      end
    end
  end
end
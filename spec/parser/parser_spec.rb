require 'spec_helper'

Parser = Norn::Parser

describe Parser do
  it "#strip_xml" do
    Generator.run(Generator::Stream) do |stream, i|
      stringified = Parser.strip_xml(stream.chunks.join)
      expect(stringified.include?("<"))
        .to be(false)
      expect(stringified.include?(">"))
        .to be(false)
    end
  end
end
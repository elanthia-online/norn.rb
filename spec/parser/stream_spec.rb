require 'spec_helper'

StreamDecoder = Norn::Parser::StreamDecoder

describe StreamDecoder do
  def test_inv_stream(stream)
    actual = Inv.fetch
    expect(actual.size)
      .to eq(stream.contents.size), %{
        :inv stream failed parsing

        tag    : #{stream.chunks.join}
        chunks : #{stream.chunks.size}
        actual : #{actual}
        open   : #{StreamDecoder.open(stream.chunks.join)}
        close  : #{StreamDecoder.close(stream.chunks.join)}
        content: #{StreamDecoder.content(stream.chunks.join)}
      }
  end

  def test_bounty_stream(stream)
    # TODO
  end

  def test_thought_stream(stream)
    # TODO
  end

  describe '#update' do
    it "updates streams" do
      Generator.run(Generator::Stream) do |stream, i|
        chunks = stream.chunks.clone

        until chunks.empty?
          StreamDecoder.update chunks.shift
        end

        expect(StreamDecoder.buffer.size)
          .to eq(0)

        case stream.type
        when :bounty
          test_bounty_stream(stream)
        when :inv
          test_inv_stream(stream)
        when :thoughts
          test_thought_stream(stream)
        else
          raise Exception.new "unhandled stream type : #{stream.type}"
        end
      end
    end
  end
end
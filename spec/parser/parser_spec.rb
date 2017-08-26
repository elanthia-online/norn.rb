require 'spec_helper'
Parser = Norn::Parser

describe Parser do
  def assert_parser_empty!
    open_tags = Parser::STATE.fetch(:tags)
    expect(open_tags.size)
      .to(eq(0), %{
        size: #{open_tags.size}
        open: #{open_tags}
      })
  end

  it "#peek", focus: false do
    puts Parser.peek " ,".chars
    puts Parser.peek "(sitting),".chars
    puts Parser.peek "(stunned) and".chars
    puts Parser.peek "lying down.".chars
  end

  it "#parse" do 
    Generator.one_of(
      Generator::Hand, 
      Generator::Component, 
      Generator::Roundtime,
      Generator::Status,
      Generator::Stream,
      Generator::Style,
    ) do |tag|
      # Norn.log(tag.string || tag.chunks, :parse)

      if tag.chunks
        tag.chunks.each do |chunk|
          Parser.parse(chunk)
        end
      else
        Parser.parse(tag.string)
      end

      open_tags = Parser::STATE.fetch(:tags)
      
      expect(open_tags.size)
        .to(eq(0), %{
          size: #{open_tags.size}
          open: #{open_tags}
           tag: #{tag.string || tag.chunks}
        })
    end
  end

  it "#parse -> multi", focus: false do
    Generator.sample("misc", "multi") do |sample|
      Parser.parse sample

      assert_parser_empty!
    end
  end

  it "#parse -> sep" do
    Generator.sample("misc", "sep") do |sample|
      Parser.parse sample
      assert_parser_empty!
    end
  end

  it "#parse -> a", focus: false do
    Generator.sample("misc", "a") do |sample|
      Parser.parse sample
      assert_parser_empty!
    end
  end

  it "#parse -> roomdesc", focus: true do
    Generator.sample("style", "room-desc") do |sample|
      Parser.parse sample

      assert_parser_empty!

      expect(Room.desc)
        .not_to be_nil

      expect(Room.title)
        .not_to be_nil
      
      expect(Room.desc.objs)
        .not_to be_empty
    end
  end

  it "#parse -> style -> roomobjs", focus: false do
    Generator.sample("component", "room-objs") do |sample|
      Parser.parse sample

      assert_parser_empty!

      expect(Room.objs.first.status.size)
        .to be > 0

      expect(Room.objs.size)
        .to be > 0
    end
  end

  it "#parse -> dialog-data -> spells", focus: false do
    Generator.sample("dialog-data", "spells") do |sample|
      Parser.parse sample

      assert_parser_empty!
    end
  end

  it "updates components", focus: false do
    Generator.run(Generator::Component) do |component, i|
      chunks = component.chunks.clone
      Parser.parse(chunks.shift) until chunks.empty?
    
      expected     = component.exists.size
      registry_key = component.type.split(" ").last.to_sym

      actual = Room.send registry_key

      assert_parser_empty!
          
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

  it "updates statuses", focus: false do
    Generator.run(Generator::Status) do |status|
      Parser.parse(status.string)
      assert_parser_empty!
      actual = Status.send(status.kind.to_boolean_method)
      expect(status.visible.downcase == "y").to eq(actual), %{
           tag : #{status.string}
        status : #{status}
        actual : #{actual}
      }
    end
  end

  def test_inv_stream(stream)
    actual = Inv.fetch
    expect(actual.size)
      .to eq(stream.contents.size), %{
        :inv stream failed parsing

        tag    : #{stream.chunks.join}
        chunks : #{stream.chunks.size}
        actual : #{actual}
      }
  end

  def test_bounty_stream(stream)
    # TODO
  end

  def test_thought_stream(stream)
    # TODO
  end

  it "updates inventory stream", focus: false do
    Generator.run(Generator::Stream, method: :inv) do |stream, i|
  
      chunks = stream.chunks.clone

      Parser.parse(chunks.shift) until chunks.empty?

      assert_parser_empty!

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

  it "updates streams", focus: false do
    Generator.run(Generator::Stream) do |stream, i|
      chunks = stream.chunks.clone

      Parser.parse(chunks.shift) until chunks.empty?

      assert_parser_empty!

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
require 'spec_helper'
Tag = Norn::Parser::Tag

describe Tag do
  it "#new" do 
    tag = Tag.new
    
    expect(tag.open?)
      .to be(true)
    
    tag.name = :hand

    expect(tag.name)
      .to eq(:hand)

  end

  it "#attrs=" do
    tag = Tag.new
    tag.name = :hand
    tag.attrs = "id='1234'"

    expect(tag.attrs[:id].to_i)
      .to eq(1234)
  end
end
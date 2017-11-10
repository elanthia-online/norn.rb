# encoding: US-ASCII
require 'spec_helper'

describe Status do
  it "parses statuses" do
    expect(Status.match(%{(sitting).}))
      .to eq %i{sitting}
    
    expect(Status.match(%{(dead),}))
      .to eq %i{dead}
    
    expect(Status.match(%{who is dead,}))
      .to eq %i{dead}
    
    expect(Status.match(%{who is dead.}))
      .to eq %i{dead}
    
    expect(Status.match(%{that appears dead.}))
      .to eq %i{dead}
    
    expect(Status.match(%{that appears to be stunned.}))
      .to eq %i{stunned}
  end
end
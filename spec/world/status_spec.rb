require 'spec_helper'

describe Norn::Status do
  it "parses statuses" do
    expect(described_class.match(%{(sitting).}))
      .to eq %i{sitting}
    
    expect(described_class.match(%{(dead),}))
      .to eq %i{dead}
    
    expect(described_class.match(%{who is dead,}))
      .to eq %i{dead}
    
    expect(described_class.match(%{who is dead.}))
      .to eq %i{dead}
    
    expect(described_class.match(%{that appears dead.}))
      .to eq %i{dead}
    
    expect(described_class.match(%{that appears to be stunned.}))
      .to eq %i{stunned}
  end
end
# encoding: US-ASCII
require 'spec_helper'

describe Status do
  string = %{Also here: Lord Kirackus, Kasori (sitting)}
  it "parses statuses" do
    puts Status.parse_also_here(string).inspect
  end
end
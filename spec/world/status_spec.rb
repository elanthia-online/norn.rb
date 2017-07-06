require 'spec_helper'
require 'norn/world/status'

describe Status do
  describe '#update' do
    it "updates statuses" do
      100.times do
        status = Generator.status
        Status.update(status[:string])
        expect(Status.send(status[:kind].to_boolean_method)).to be Status.cast(status[:visible])
      end
    end
  end
end
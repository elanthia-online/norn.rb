require "bundler/setup"
require "norn"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Generator
  STATUSES = [
    "STUNNED",
    "PRONE",
  ]

  STATES = [
    Status::Y,
    Status::N,
  ]

  def self.status
    kind    = STATUSES.sample
    visible = STATES.sample
    { 
      string:  "<indicator id='Icon#{kind}' visible='#{visible}'/>",
      visible: visible,
      kind:    kind,
    }
  end
end
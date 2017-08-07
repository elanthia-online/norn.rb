require "ostruct"
require "securerandom"
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
  class String
    CHARS = ("a".."z").to_a + ("A".."Z").to_a

    def self.random_char
      CHARS.sample
    end

    def self.random(min = 0, max = 10)
      Array.new(Integer.random(min, max)) do
        random_char
      end.join("")
    end
  end

  class Integer
    def self.random(min = -1000, max = 1000)
      rand(min..max).floor
    end
  end


  def self.run(mods, **args)
    (args[:samples] || 1_000).times do |i|
      if mods.is_a?(Array)
        yield *mods.map(&:generate), i
      else
        yield mods.send(:generate), i
      end
    end
  end

  def self.sample(type, subtype)
    File.read(File.join(__dir__, "samples", type.to_s, subtype.to_s + ".tag"))
  end
  
  Dir[File.dirname(__FILE__) + '/generators/**/*.rb'].each do |file|
    require file 
  end
end
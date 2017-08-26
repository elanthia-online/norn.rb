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

  def self.one_of(*mods, samples: 1_000)
    samples.times do |i|
      test = mods.sample.send(:generate)
      begin
        yield test, i
      rescue => exception
        raise $!, "case: #{test}: #{$!}", $!.backtrace
       
      end
    end
  end

  def self.run(*mods, samples: 1_000, method: :generate)
    samples.times do |i|
      yield *mods.map(&method), i
    end
  end

  def self.sample(type, subtype)
    yield File.read(File.join(__dir__, "samples", type.to_s, subtype.to_s + ".tag"))
  end
  
  Dir[File.dirname(__FILE__) + '/generators/**/*.rb'].each do |file|
    require file 
  end
end
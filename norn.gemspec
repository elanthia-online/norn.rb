# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'norn/version'

Gem::Specification.new do |spec|
  spec.name          = "norn"
  spec.version       = Norn::VERSION
  spec.authors       = ["ondreian"]
  spec.email         = ["benjamin.clos+github@gmail.com"]
  spec.summary       = "Gemstone IV scripting engine"
  spec.description   = "Gemstone IV scripting engine"
  spec.homepage      = "https://github/ondreian/norn.rb"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "oga", "~> 2.11", ">= 2.0.0"
  spec.add_runtime_dependency "tomlrb", "~> 1.2", ">= 1.2.6"
  spec.add_runtime_dependency "sequel",  '~> 5.5'
  spec.add_runtime_dependency "sqlite3", '~> 1.3', '>= 1.3.13'
  spec.add_runtime_dependency "rugged",  '~> 0.26.0'
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry", "~> 0"
  spec.add_development_dependency "highline", "~> 0"
end

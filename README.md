# Norn [![Build Status](https://travis-ci.org/ondreian/norn.rb.svg?branch=master)](https://travis-ci.org/ondreian/norn.rb) [![Build status](https://ci.appveyor.com/api/projects/status/8b0y5sbw5e6ejmj0?svg=true)](https://ci.appveyor.com/project/ondreian/norn-rb)

A new scripting engine for Gemstone IV that should be a drop-in replacement for Lich.rb

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'norn'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install norn

## Usage

### ProfanityFE

Norn can be used easily with [ProfanityFE](https://github.com/ondreian/ProfanityFE), due to its ability to connect to arbitrary ports for the game stream.
The Norn default console (`bin/console`) will prompt for user login information, which will login to the specified character.
Launching Profanity to read from port 8383 (`ruby profanity.rb --port=8383`) will cause ProfanityFE to connect to Norn for the game stream.
Norn's connection to ProfanityFE can be confirmed by executing `/i Room.title` inside ProfanityFE, which should return the title of the current room.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ondreian/norn. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

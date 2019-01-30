# StubRequests

This gem attempts to solve a problem I've had for the longest time with WebMock. I found it difficult to maintain all the various stub requests. 

When something changes, I have to update every single stub_request. This gem allows me to only update the crucial parts while abstracting away things like service URI's, endpoint definitions and focus on the important things.

This is achieve by keeping a registry over the services and endpoints.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stub_requests'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stub_requests

## Usage

# TODO: Add some useful information about how to use the gem

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhenrixon/stub_requests. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StubRequests project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mhenrixon/stub_requests/blob/master/CODE_OF_CONDUCT.md).

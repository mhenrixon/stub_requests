# StubRequests

[![Build Status](https://travis-ci.org/mhenrixon/stub_requests.svg?branch=master)](https://travis-ci.org/mhenrixon/stub_requests) [![Maintainability](https://api.codeclimate.com/v1/badges/c9217e458c2a77fff1bc/maintainability)](https://codeclimate.com/github/mhenrixon/stub_requests/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/c9217e458c2a77fff1bc/test_coverage)](https://codeclimate.com/github/mhenrixon/stub_requests/test_coverage)

This gem attempts to solve a problem I've had for the longest time with WebMock. I found it difficult to maintain all the various stub requests.

When something changes, I have to update every single stub_request. This gem allows me to only update the crucial parts while abstracting away things like service URI's, endpoint definitions and focus on the important things.

This is achieve by keeping a registry over the services and endpoints.

<!-- MarkdownTOC -->

- Installation
- Usage
- Development
- Contributing
- License
- Code of Conduct

<!-- /MarkdownTOC -->

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

To use the gem we need to register some service endpoints. In the following example we are connecting to a rails inspired service. The naming of the service_id and endpoint_id's do not matter. This is just how we look things up in the registry.

```ruby
StubRequests.register_service(:google_ads, "https://api.google.com/v5") do |s|
  s.register_endpoint(:index, :get, "ads")
  s.register_endpoint(:show, :get, "ads/:id")
  s.register_endpoint(:update, :patch, "ads/:id")
  s.register_endpoint(:create, :post, "ads")
  s.register_endpoint(:destroy, :delete, "ads/:id")
end
```

Now we have a list of endpoints we can stub.

```ruby
StubRequests.stub_endpoint(:google_ads, :index).to_return(code: 204, body: "")

# This is the equivalent of doing the following in WebMock
Settings.google_ads_base_uri = "https://api.google.com/v5"

WebMock.stub_request(:get, "#{Settings.google_ads_base_uri}/ads")
  .to_return(status: 204, body: "")
```

So far so good but not much of a gain yet. The real power comes when we don't have to duplicate our url replacements.

```ruby
StubRequests.stub_endpoint(:google_ads, :update, id: 1)
  .with(body: request_body.to_json)
  .to_return(code: 200, body: response_body.to_json)

# This is the equivalent of doing the following in WebMock
Settings.google_ads_base_uri = "https://api.google.com/v5"

WebMock.stub_request(:patch, "#{Settings.google_ads_base_uri}/ads/#{id}")
  .with(body: request_body.to_json)
  .to_return(status: 200, body: response_body.to_json)
```

I hope by now you are starting to see why I created this gem? First of all we reduce a lot of duplication. Imagine a codebase with thousands of these stubbed request where you always have to look at the defined URL to understand which request is actually being called? Madness!!


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mhenrixon/stub_requests. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the StubRequests project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/mhenrixon/stub_requests/blob/master/CODE_OF_CONDUCT.md).

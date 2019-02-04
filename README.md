# StubRequests

## Badges

[![Build Status](https://travis-ci.org/mhenrixon/stub_requests.svg?branch=master)](https://travis-ci.org/mhenrixon/stub_requests) [![Maintainability](https://api.codeclimate.com/v1/badges/c9217e458c2a77fff1bc/maintainability)](https://codeclimate.com/github/mhenrixon/stub_requests/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/c9217e458c2a77fff1bc/test_coverage)](https://codeclimate.com/github/mhenrixon/stub_requests/test_coverage)

This gem attempts to solve a problem I've had for the time with WebMock.

When something changes, I have to update every single stub_request.

This gem allows me to only update the crucial parts while abstracting away things like service URI's, endpoint definitions and focus on the important things.

This is achieve by keeping a registry over the service endpoints.

<!-- MarkdownTOC -->

- [Required ruby version](#required-ruby-version)
- [Installation](#installation)
- [Usage](#usage)
  - [Register service endpoints](#register-service-endpoints)
  - [Stubbing service endpoints](#stubbing-service-endpoints)
  - [Metrics](#metrics)
  - [Observing endpoint invocations](#observing-endpoint-invocations)
- [Future Improvements](#future-improvements)
  - [API Client Gem](#api-client-gem)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)
- [Code of Conduct](#code-of-conduct)

<!-- /MarkdownTOC -->

<a id="required-ruby-version"></a>
## Required ruby version

Ruby version >= 2.3

<a id="installation"></a>
## Installation

Add this line to your application's Gemfile:

```ruby
gem "stub_requests"
```

And then execute:

```
bundle
```

Or install it yourself as:

```
gem install stub_requests
```

<a id="usage"></a>
## Usage

To use the gem we need to register some service endpoints. In the following example we are connecting to a rails inspired service.

The naming of the `service_id` and `endpoint_id`'s is irrelevant. This is just how we look things up in the registry.

<a id="register-service-endpoints"></a>
### Register service endpoints

```ruby
StubRequests.register_service(:google_ads, "https://api.google.com/v5") do
  register(:index, :get, "ads")
  register(:show, :get, "ads/:id")
  register(:update, :patch, "ads/:id")
  register(:create, :post, "ads")
  register(:destroy, :delete, "ads/:id")
end
```

Now we have a list of endpoints we can stub.

<a id="stubbing-service-endpoints"></a>
### Stubbing service endpoints

```ruby
StubRequests.stub_endpoint(:google_ads, :index)
            .to_return(code: 204, body: "")

# This is the equivalent of doing the following in WebMock
Settings.google_ads_base_uri = "https://api.google.com/v5"

WebMock.stub_request(:get, "#{Settings.google_ads_base_uri}/ads")
       .to_return(status: 204, body: "")
```

```ruby
StubRequests.stub_endpoint(:google_ads, :update, id: 1) do
  with(body: request_body.to_json)
  to_return(code: 200, body: response_body.to_json)
end

# This is the equivalent of doing the following in WebMock
Settings.google_ads_base_uri = "https://api.google.com/v5"

WebMock.stub_request(:patch, "#{Settings.google_ads_base_uri}/ads/#{id}")
       .with(body: request_body.to_json)
       .to_return(status: 200, body: response_body.to_json)
```

This reduces the need to spread out URI's in the test suite without having to resort to shared examples.

<a id="metrics"></a>
### Metrics

Metrics collection are by default turned off. It can be turned on by the following code.

```ruby
StubRequests.configure do |config|
  config.record_metrics = true
end
```

<a id="observing-endpoint-invocations"></a>
### Observing endpoint invocations

```ruby
callback = lambda do |request|
  p request
  binding.pry
end

StubRequests.subscribe_to(:document_service, :show, :get, callback)

# TODO: Needs more thinking through this
```

```ruby
StubRequests.unsubscribe_from(:document_service, :show, :get)

# TODO: Needs more thinking through this
```

<a id="future-improvements"></a>
## Future Improvements

<a id="api-client-gem"></a>
### API Client Gem

Since we have a service + endpoint registry, I was thinking it might make
sense to make this into an API client. Not sure yet, maybe this will become multiple gems in the future so that someone can pick and choose.

Anyway, the idea was to provide endpoint calls in production and stubbed
requests in tests using the same registry.

<a id="development"></a>
## Development

After checking out the repo, run `bin/setup` to install dependencies.

Then, run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

<a id="contributing"></a>
## Contributing

Bug reports and pull requests are welcome on GitHub at:
[issues](https://github.com/mhenrixon/stub_requests).

This project is intended to be a safe, welcoming space for collaboration, and
contributors are expected to adhere to the [Contributor Covenant](cc) code of conduct.

<a id="license"></a>
## License

The gem is available as open source under the terms of the [MIT License](mit).

<a id="code-of-conduct"></a>
## Code of Conduct

Everyone interacting in the StubRequests project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the [code of conduct](coc).

[coc]:https://github.com/mhenrixon/stub_requests/blob/master/CODE_OF_CONDUCT.md
[cc]: http://contributor-covenant.org
[mit]: https://opensource.org/licenses/MIT

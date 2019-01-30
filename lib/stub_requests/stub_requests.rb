# frozen_string_literal: true

#
# Abstraction over WebMock that reduces the need to spread out stub_request everywhere.
# @since 0.1.0
#
module StubRequests
  class Error < StandardError; end
  class UriSegmentMismatch < Error; end
  class EndpointNotFound < Error; end
  class ServiceNotFound < Error; end
  class ServiceNotRegistered < Error; end

  extend self
  include StubRequests::API

  attr_accessor :logger

  def version
    StubRequests::VERSION
  end
end

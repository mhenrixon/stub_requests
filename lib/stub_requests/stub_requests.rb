# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Error is a base class for all gem errors
  #
  class Error < StandardError; end

  #
  # ServiceHaveEndpoints is raised to prevent overwriting a registered service's endpoints
  #
  class ServiceHaveEndpoints < StandardError
    def initialize(service)
      super("Service with id #{service.id} have already been registered. #{service}")
    end
  end

  #
  # InvalidType is raised when an argument is invalid
  #
  class InvalidType < Error
    def initialize(actual:, expected:)
      super("Expected `#{actual}` to be any of [#{expected}]")
    end
  end

  #
  # EndpointNotFound is raised when an endpoint cannot be found
  #
  class EndpointNotFound < Error; end

  #
  # ServiceNotFound is raised when a service cannot be found
  #
  class ServiceNotFound < Error
    def initialize(service_id)
      super("Couldn't find a service with id=:#{service_id}")
    end
  end

  #
  # UriSegmentMismatch is raised when a segment cannot be replaced
  #
  class UriSegmentMismatch < Error; end

  #
  # InvalidUri is raised when a URI is invalid
  #
  class InvalidUri < Error
    def initialize(uri)
      super("'#{uri}' is not a valid URI.")
    end
  end

  # extends "self"
  # @!parse extend self
  extend self

  # includes "UriFor" and extends "UriFor"
  # using the API.included callback
  # @!parse include UriFor
  # @!parse extend UriFor

  # includes "API" and extends "API"
  # using the API.included callback
  # @!parse include API
  # @!parse extend API
  include API

  #
  # @!attribute [rw] logger
  #   @return [Logger] the logger to use in the gem
  attr_accessor :logger

  #
  # The current version of the gem
  #
  #
  # @return [String] version string, `"1.0.0"`
  #
  def version
    VERSION
  end
end

# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
# @since 0.1.0
#
module StubRequests
  #
  # Error is a base class for all gem errors
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Error < StandardError; end

  #
  # ServiceHaveEndpoints is raised to prevent overwriting a registered service's endpoints
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class ServiceHaveEndpoints < StandardError
    def initialize(service)
      super("Service with id #{service.id} have already been registered. #{service}")
    end
  end

  #
  # InvalidType is raised when an argument is invalid
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class InvalidType < Error
    def initialize(actual:, expected:)
      super("Expected `#{actual}` to be any of [#{expected}]")
    end
  end

  #
  # EndpointNotFound is raised when an endpoint cannot be found
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class EndpointNotFound < Error; end

  #
  # ServiceNotFound is raised when a service cannot be found
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class ServiceNotFound < Error
    def initialize(service_id)
      super("Couldn't find a service with id=:#{service_id}")
    end
  end

  #
  # UriSegmentMismatch is raised when a segment cannot be replaced
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class UriSegmentMismatch < Error; end

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

  def version
    VERSION
  end
end

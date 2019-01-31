# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
# @since 0.1.0
#
module StubRequests
  #
  # Class Error a base class for all gem errors
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Error < StandardError; end

  #
  # Class InvalidArgument is raised when an argument is invalid
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class InvalidArgument < StandardError
    def initialize(attribute, value, reason)

    end
  end

  #
  # Class EndpointNotFound is raised when an endpoint cannot be found
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class EndpointNotFound < Error; end

  #
  # Class ServiceNotFound is raised when a service cannot be found
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class ServiceNotFound < Error
    def initialize(service_id)
      super("Couldn't find a service with id=:#{service_id}")
    end
  end

  #
  # Class UriSegmentMismatch is raised when a segment cannot be replaced
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

  attr_accessor :logger

  def version
    VERSION
  end
end

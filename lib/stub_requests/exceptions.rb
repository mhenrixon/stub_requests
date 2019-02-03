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
  # PropertyDefined is raised when trying to add the same property twice
  #
  class PropertyDefined < Error
    def initializer(name, definition)
      type    = definition[:type]
      default = definition[:default]
      super("Property ##{name} was already defined with(type: #{type}, default: #{default})")
    end
  end

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
end

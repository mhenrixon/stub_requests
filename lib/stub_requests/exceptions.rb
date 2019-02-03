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
  # EndpointNotFound is raised when an endpoint cannot be found
  #
  class EndpointNotFound < Error; end

  #
  # InvalidType is raised when an argument is invalid
  #
  class InvalidType < Error
    def initialize(actual, expected)
      super("Expected `#{actual}` to be any of [#{expected}]")
    end
  end

  #
  # InvalidArgumentType is raised when an argument is not of the expected type
  #
  class InvalidArgumentType < Error
    #
    # @param [Symbol] name the name of the argument
    # @param [Object] actual the actual value of the argument
    # @param [Array<Class>, Array<Module>] expected the types the argument is expected to be
    #
    def initialize(name:, actual:, expected:)
      super("The argument `:#{name}` was `#{actual}`, expected any of [#{expected.join(', ')}]")
    end
  end

  #
  # InvalidUri is raised when a URI is invalid
  #
  class InvalidUri < Error
    def initialize(uri)
      super("'#{uri}' is not a valid URI.")
    end
  end

  #
  # PropertyDefined is raised when trying to add the same property twice
  #
  class PropertyDefined < Error
    def initialize(name:, type:, default:)
      super("Property ##{name} was already defined as `{ type: #{type}, default: #{default ? default : "nil"} }")
    end
  end

  #
  # ServiceHaveEndpoints is raised to prevent overwriting a registered service's endpoints
  #
  class ServiceHaveEndpoints < StandardError
    def initialize(service)
      super("Service with id #{service.id} have already been registered. #{service}")
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
end

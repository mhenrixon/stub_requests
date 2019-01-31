# frozen_string_literal: true

#
# Abstraction over WebMock that reduces the need to spread out stub_request everywhere.
# @since 0.1.0
#
module StubRequests
  #
  # Class Error provides a base class for all gem errors
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Error < StandardError; end

  #
  # Class UriSegmentMismatch is raised when a segment cannot be replaced
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class UriSegmentMismatch < Error; end

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

  extend self
  include StubRequests::API

  attr_accessor :logger

  def version
    StubRequests::VERSION
  end
end

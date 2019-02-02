# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Service provides details for a registered service
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Service
    include ArgumentValidation
    include Comparable

    # @!attribute [rw] id
    #   @return [EndpointRegistry] the id of the service
    attr_reader :id

    # @!attribute [rw] uri
    #   @return [EndpointRegistry] the base uri to the service
    attr_reader :uri

    # @!attribute [rw] endpoints
    #   @return [EndpointRegistry] a list with defined endpoints
    attr_reader :endpoints

    #
    # Initializes a new instance of a Service
    #
    # @param [Symbol] service_id the id of this service
    # @param [String] service_uri the base uri to reach the service
    #
    def initialize(service_id, service_uri)
      validate! service_id,  is_a: Symbol
      validate! service_uri, is_a: String

      @id        = service_id
      @uri       = service_uri
      @endpoints = EndpointRegistry.new
    end

    #
    # Check if the endpoint registry has endpoints
    #
    # @return [true,false]
    #
    def endpoints?
      endpoints.any?
    end

    #
    # Returns a nicely formatted string with this service
    #
    # @return [String]
    #
    def to_s
      [
        +"#<#{self.class}",
        +" id=#{id}",
        +" uri=#{uri}",
        +" endpoints=#{endpoints.endpoints_string}",
        +">",
      ].join("")
    end

    def <=>(other)
      id <=> other.id
    end

    def hash
      [id, self.class].hash
    end

    alias eql? ==
  end
end

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
    include Comparable
    include Properties

    # @!attribute [rw] id
    #   @return [EndpointRegistry] the id of the service
    property :id, type: Symbol

    # @!attribute [rw] uri
    #   @return [EndpointRegistry] the base uri to the service
    property :uri, type: String

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
      self.id    = service_id
      self.uri   = service_uri
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

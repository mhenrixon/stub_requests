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
    # includes "Comparable"
    # @!parse include Comparable
    include Comparable
    # includes "Concerns::Property"
    # @!parse include Concerns::Property
    include Concerns::Property
    # includes "Concerns::RegisterVerb"
    # @!parse include Concerns::RegisterVerb
    include Concerns::RegisterVerb

    # @!attribute [rw] id
    #   @return [Symbol] the id of the service
    property :id, type: Symbol

    # @!attribute [rw] uri
    #   @return [String] the base uri to the service
    property :uri, type: String

    #
    # Initializes a new instance of a Service
    #
    # @param [Symbol] service_id the id of this service
    # @param [String] service_uri the base uri to reach the service
    #
    def initialize(service_id, service_uri)
      self.id    = service_id
      self.uri   = service_uri
    end

    #
    # Register and endpoint for this service
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    # @param [Symbol] verb the HTTP verb/method
    # @param [String] path the path to the endpoint
    #
    # @return [Endpoint] the endpoint that was registered
    #
    def register(endpoint_id, verb, path)
      endpoint = Endpoint.new(
        service_id: id,
        service_uri: uri,
        endpoint_id: endpoint_id,
        verb: verb,
        path: path,
      )
      EndpointRegistry.instance.register(endpoint)
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
    # The endpoints for this service
    #
    #
    # @return [Array<Endpoints>]
    #
    def endpoints
      EndpointRegistry[id]
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
        +" endpoints=#{endpoints_string}",
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

    #
    # Returns a nicely formatted string with an array of endpoints
    #
    #
    # @return [String]
    #
    def endpoints_string
      "[#{endpoints_as_string}]"
    end

    private

    def endpoints_as_string
      endpoints.map(&:to_s).join(",") if endpoints?
    end
  end
end

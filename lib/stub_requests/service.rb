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
  class Service
    include ArgumentValidation
    include Comparable

    # @!attribute [rw] id
    #   @return [EndpointRegistry] the id of the service
    attr_reader :id

    # @!attribute [rw] uri
    #   @return [EndpointRegistry] the base uri to the service
    attr_reader :uri

    # @!attribute [rw] endpoint_registry
    #   @return [EndpointRegistry] a list with defined endpoints
    attr_reader :endpoint_registry

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
      @endpoint_registry = EndpointRegistry.new
    end

    #
    # Registers a new endpoint or updates an existing one
    #
    #
    # @param [Symbol] endpoint_id the id of this Endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template the URI to reach the endpoint
    # @param [optional, Hash<Symbol>] default_options default options
    #
    # @return [Endpoint] either the new endpoint or the updated one
    #
    # :reek:LongParameterList { max_params: 5 }
    def register_endpoint(endpoint_id, verb, uri_template, default_options = {})
      endpoint_registry.register(endpoint_id, verb, uri_template, default_options)
    end

    #
    # Check if the endpoint registry has endpoints
    #
    # @return [true,false]
    #
    def endpoints?
      endpoint_registry.any?
    end

    #
    # Gets an endpoint from the {#endpoint_registry} collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @raise [EndpointNotFound] when the endpoint couldn't be found
    #
    # @return [Endpoint]
    #
    def get_endpoint!(endpoint_id)
      endpoint_registry.get!(endpoint_id)
    end

    #
    # Gets an endpoint from the {#endpoint_registry} collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @return [Endpoint, nil]
    #
    def get_endpoint(endpoint_id)
      endpoint_registry.get(endpoint_id)
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
        +" endpoints=#{endpoint_registry.endpoints_string}",
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

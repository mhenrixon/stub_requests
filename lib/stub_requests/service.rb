# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
# @since 0.1.0
#
module StubRequests
  #
  # Class Service provides details for a registered service
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Service
    # @!attribute [rw] id
    #   @return [Endpoints] the id of the service
    attr_accessor :id

    # @!attribute [rw] uri
    #   @return [Endpoints] the base uri to the service
    attr_accessor :uri

    # @!attribute [rw] endpoints
    #   @return [Endpoints] a list with defined endpoints
    attr_accessor :endpoints

    #
    # Initializes a new instance of a Service
    #
    # @param [Symbol] service_id the id of this service
    # @param [String] service_uri the base uri to reach the service
    #
    def initialize(service_id, service_uri)
      raise InvalidArgument, service_id: service_id if service_id.blank?
      raise InvalidArgument, service_uri: service_uri if service_id.blank?

      @id        = service_id
      @uri       = service_uri
      @endpoints = Endpoints.new
    end

    #
    # Registers a new endpoint or updates an existing one
    #
    #
    # @param [Symbol] endpoint_id the id of this Endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template the URI to reach the endpoint
    # @param [optional, Hash<Symbol>] default_options default request options
    #
    # @return [Endpoint] either the new endpoint or the updated one
    #
    def register_endpoint(endpoint_id, verb, uri_template, default_options = {})
      endpoint =
        if endpoints.registered?(endpoint_id)
          endpoints.update(endpoint_id, verb, uri_template, default_options)
        else
          Endpoint.new(endpoint_id, verb, uri_template, default_options)
        end

      endpoints.register(endpoint)
    end

    #
    # Gets an endpoint from the {#endpoints} collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @raise [EndpointNotFound] when the endpoint couldn't be found
    #
    # @return [Endpoint]
    #
    def get_endpoint!(endpoint_id)
      endpoints.get!(endpoint_id)
    end

    #
    # Gets an endpoint from the {#endpoints} collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @return [Endpoint, nil]
    #
    def get_endpoint(endpoint_id)
      endpoints.get(endpoint_id)
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
  end
end

# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
# @since 0.1.0
#
module StubRequests
  #
  # Class Endpoints holds a collection of {Endpoint}
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Endpoints
    include Enumerable

    #
    # @!attribute [rw] endpoints
    #   @return [Concurrent::Map] a map with endpoints
    attr_accessor :endpoints

    def initialize
      @endpoints = Concurrent::Map.new
    end

    #
    # Required by Enumerable
    #
    #
    # @return [Array<Endpoint>] an array of endpoints
    #
    # @yield used by Enumerable
    #
    def each(&block)
      @endpoints.each(&block)
    end

    #
    # Registers an endpoint in the collection
    #
    # @param [Endpoint] endpoint the endpoint to register
    #
    # @return [Endpoint]
    #
    def register(endpoint)
      @endpoints[endpoint.id] = endpoint
      endpoint
    end

    #
    # Check if an endpoint is registered
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @return [true, false]
    #
    def registered?(endpoint_id)
      @endpoints.key?(endpoint_id)
    end

    #
    # Updates an endpoint
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] default_options
    # @option default_options [optional, Hash<Symbol>] :request see {API.prepare_request}
    # @option default_options [optional, Hash<Symbol>] :response see {API.prepare_response}
    # @option default_options [optional, Array, Exception, StandardError, String] :error see {#API.prepare_error}
    # @option default_options [optional, TrueClass] :timeout if the stubbed request should raise Timeout
    #
    # @raise [EndpointNotFound] when the endpoint couldn't be found
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(endpoint_id, verb, uri_template, default_options)
      endpoint = get!(endpoint_id)
      endpoint.update(verb, uri_template, default_options)
      register(endpoint)
    end

    #
    # Removes an endpoint from the collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint, `:file_service`
    #
    # @return [Endpoint] the endpoint that was removed
    #
    def remove(endpoint_id)
      @endpoints.delete(endpoint_id)
    end

    #
    # Fetches an endpoint from the collection
    #
    # @param [<type>] endpoint_id <description>
    #
    # @return [Endpoint]
    #
    def get(endpoint_id)
      @endpoints[endpoint_id]
    end

    #
    # Fetches an endpoint from the collection or raises an error
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @raise [EndpointNotFound] when an endpoint couldn't be found
    #
    # @return [Endpoint, nil]
    #
    def get!(endpoint_id)
      get(endpoint_id) || raise(EndpointNotFound, "Couldn't find an endpoint with id=:#{endpoint_id}")
    end

    #
    # Returns a descriptive string with all endpoints in the collection
    #
    # @return [String]
    #
    def to_s
      [
        +"#<#{self.class} endpoints=",
        +endpoints_string,
        +">",
      ].join("")
    end

    #
    # Returns a nicely formatted string with an array of endpoints
    #
    #
    # @return [<type>] <description>
    #
    def endpoints_string
      "[#{endpoints_as_string}]"
    end

    private

    def endpoints_as_string
      endpoints.values.map(&:to_s).join(",") if endpoints.size.positive?
    end
  end
end

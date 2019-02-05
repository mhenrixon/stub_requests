# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Endpoints manages a collection of endpoints
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Endpoints
    include Enumerable

    #
    # @!attribute [rw] endpoints
    #   @return [Concurrent::Map<Symbol, Endpoint>] a map with endpoints
    attr_reader :endpoints

    def initialize
      @endpoints = Concurrent::Map.new
    end

    #
    # Required by Enumerable
    #
    # @return [Concurrent::Map<Symbol, Service>] a map with endpoints
    #
    # @yield used by Enumerable
    #
    def each(&block)
      endpoints.each(&block)
    end

    #
    # Registers an endpoint in the collection
    #
    # @param [Symbol] endpoint_id the id of this Endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template the URI to reach the endpoint
    #
    # @return [Endpoint]
    #
    # :reek:LongParameterList { max_params: 4 }
    def register(endpoint_id, verb, uri_template)
      endpoint =
        if (endpoint = find(endpoint_id))
          StubRequests.logger.warn("Endpoint already registered: #{endpoint}")
          endpoint.update(verb, uri_template)
        else
          Endpoint.new(endpoint_id, verb, uri_template)
        end

      endpoints[endpoint.id] = endpoint
      endpoint
    end

    #
    # Updates an endpoint
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request request options
    # @option options [optional, Hash<Symbol>] :response options
    # @option options [optional, Array, Exception, StandardError, String] :error to raise
    # @option options [optional, TrueClass] :timeout raise a timeout error?
    #
    # @raise [EndpointNotFound] when the endpoint couldn't be found
    #
    # @return [Endpoint] returns the updated endpoint
    #
    # :reek:LongParameterList { max_params: 4 }
    def update(endpoint_id, verb, uri_template)
      endpoint = find!(endpoint_id)
      endpoint.update(verb, uri_template)
    end

    #
    # Removes an endpoint from the collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint, `:file_service`
    #
    # @return [Endpoint] the endpoint that was removed
    #
    def remove(endpoint_id)
      endpoints.delete(endpoint_id)
    end

    #
    # Fetches an endpoint from the collection
    #
    # @param [<type>] endpoint_id <description>
    #
    # @return [Endpoint]
    #
    def find(endpoint_id)
      endpoints[endpoint_id]
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
    def find!(endpoint_id)
      find(endpoint_id) || raise(EndpointNotFound, "Couldn't find an endpoint with id=:#{endpoint_id}")
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

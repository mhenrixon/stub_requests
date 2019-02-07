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
  class EndpointRegistry
    # extend "Forwardable"
    # @!parse extend Forwardable
    extend Forwardable

    # includes "Singleton"
    # @!parse include Singleton
    include Singleton
    # includes "Enumerable"
    # @!parse include Enumerable
    include Enumerable

    delegate [:each, :[], :[]=, :delete, :keys, :values] => :endpoints

    #
    # Return all endpoints for a service
    #
    # @param [Symbol] service_id the id of a registered service
    #
    # @return [Array<Endpoint>] the endpoints for the service
    #
    def self.[](service_id)
      instance.values.select { |ep| ep.service_id == service_id }
    end

    #
    # @!attribute [rw] endpoints
    #   @return [Concurrent::Map<Symbol, Endpoint>] a map with endpoints
    attr_reader :endpoints

    #
    # Initialize is used by Singleton
    #
    #
    def initialize
      reset
    end

    #
    # Resets the endpoints array (used for testing)
    #
    #
    def reset
      @endpoints = Concurrent::Map.new
    end

    #
    # The size of the endpoints array
    #
    #
    # @return [Integer]
    #
    def size
      keys.size
    end
    alias count size

    #
    # Registers an endpoint in the collection
    #
    # @param [Endpoint] endpoint the endpoint to register
    #
    # @return [Endpoint]
    #
    def register(endpoint)
      StubRequests.logger.warn("Endpoint already registered: #{endpoint}") if find(endpoint)

      self[endpoint.id] = endpoint
      endpoint
    end

    #
    # Fetches an endpoint from the collection or raises an error
    #
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @raise [EndpointNotFound] when an endpoint couldn't be found
    #
    # @return [Endpoint]
    #
    def find!(endpoint_id)
      endpoint = find(endpoint_id)
      return endpoint if endpoint

      raise EndpointNotFound, id: endpoint_id, suggestions: suggestions(endpoint_id)
    end

    #
    # Fetches an endpoint from the collection or raises an error
    #

    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @return [Endpoint, nil]

    def find(endpoint_id)
      endpoint_id = endpoint_id.id if endpoint_id.is_a?(Endpoint)
      self[endpoint_id]
    end

    #
    # Returns an array of potential alternatives
    #
    # @param [Symbol] endpoint_id the id of an endpoint
    #
    # @return [Array<Symbol>] an array of endpoint_id's
    #
    def suggestions(endpoint_id)
      Utils::Fuzzy.match(endpoint_id, keys)
    end

    #
    # Returns a descriptive string with all endpoints in the collection
    #
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

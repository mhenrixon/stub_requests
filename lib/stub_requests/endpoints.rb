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
    # @!attribute [rw] service
    #   @return [Service] the service the collection belongs to
    attr_reader :service
    #
    # @!attribute [rw] endpoints
    #   @return [Concurrent::Map<Symbol, Endpoint>] a map with endpoints
    attr_reader :endpoints

    def initialize(service)
      @service   = service
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
    # @param [String] path the URI to reach the endpoint
    #
    # @return [Endpoint]
    #
    def register(endpoint_id, verb, path)
      endpoint =
        if (endpoint = find(endpoint_id))
          StubRequests.logger.warn("Endpoint already registered: #{endpoint}")
          endpoint.update(verb, path)
        else
          Endpoint.new(service, endpoint_id, verb, path)
        end

      endpoints[endpoint.id] = endpoint
      endpoint
    end

    #
    # Convenience wrapper for register
    #
    #
    # @example **Register a get endpoint**
    # .  get("documents/:id", as: :documents_show)
    #
    # @param [String] path the path to the endpoint
    # @param [Symbol] as the id of the endpoint
    #
    # @return [Endpoint] the registered endpoint
    #
    def any(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
      register(as, __method__, path)
    end

    #
    # Convenience wrapper for register
    #
    #
    # @example **Register a get endpoint**
    # .  get("documents/:id", as: :documents_show)
    #
    # @param [String] path the path to the endpoint
    # @param [Symbol] as the id of the endpoint
    #
    # @return [Endpoint] the registered endpoint
    #
    def get(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
      register(as, __method__, path)
    end

    #
    # Register a :post endpoint
    #
    #
    # @example **Register a post endpoint**
    # .  post("documents", as: :documents_create)
    #
    # @param [String] path the path to the endpoint
    # @param [Symbol] as the id of the endpoint
    #
    # @return [Endpoint] the registered endpoint
    #
    def post(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
      register(as, __method__, path)
    end

    #
    # Register a :patch endpoint
    #
    #
    # @example **Register a patch endpoint**
    # .  patch("documents/:id", as: :documents_update)
    #
    # @param [String] path the path to the endpoint
    # @param [Symbol] as the id of the endpoint
    #
    # @return [Endpoint] the registered endpoint
    #
    def patch(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
      register(as, __method__, path)
    end

    #
    # Register a :put endpoint
    #
    #
    # @example **Register a put endpoint**
    # .  put("documents/:id", as: :documents_update)
    #
    # @param [String] path the path to the endpoint
    # @param [Symbol] as the id of the endpoint
    #
    # @return [Endpoint] the registered endpoint
    #
    def put(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
      register(as, __method__, path)
    end

    #
    # Register a :delete endpoint
    #
    #
    # @example **Register a delete endpoint**
    # .  delete("documents/:id", as: :documents_destroy)
    #
    # @param [String] path the path to the endpoint
    # @param [Symbol] as the id of the endpoint
    #
    # @return [Endpoint] the registered endpoint
    #
    def delete(path, as:) # rubocop:disable Naming/UncommunicativeMethodParamName
      register(as, __method__, path)
    end

    #
    # Updates an endpoint
    #
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] path the path to the endpoint
    #
    # @raise [EndpointNotFound] when the endpoint couldn't be found
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(endpoint_id, verb, path)
      endpoint = find!(endpoint_id)
      endpoint.update(verb, path)
    end

    #
    # Removes an endpoint from the collection
    #
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

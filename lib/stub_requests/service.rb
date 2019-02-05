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
    extend Forwardable

    delegate [:each, :[], :[]=, :to_h] => :endpoints

    include Comparable
    include Property

    # @!attribute [rw] id
    #   @return [Symbol] the id of the service
    property :id, type: Symbol

    # @!attribute [rw] uri
    #   @return [String] the base uri to the service
    property :uri, type: String

    # @!attribute [rw] endpoints
    #   @return [Endpoints] a list with defined endpoints
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
      @endpoints = Concurrent::Map.new
    end

    #
    # Check if the endpoint registry has endpoints
    #
    # @return [true,false]
    #
    def endpoints?
      endpoints.present?
    end

    #
    # Registers an endpoint in the collection
    #
    # @param [Symbol] endpoint_id the id of this Endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] path the URI to reach the endpoint
    # @param [optional, Hash<Symbol>] options default options
    #
    # @return [Endpoint]
    #
    # :reek:LongParameterList { max_params: 5 }
    def register_endpoint(endpoint_id, verb, path, options = {})
      endpoint =
        if (endpoint = find(endpoint_id))
          StubRequests.logger.warn("Endpoint already registered: #{endpoint}")
          endpoint.update(verb, path, options)
        else
          Endpoint.new(self, endpoint_id, verb, path, options)
        end

      endpoints[endpoint.id] = endpoint
      endpoint
    end
    alias register register_endpoint

    #
    # Removes an endpoint from the collection
    #
    # @param [Symbol] endpoint_id the id of the endpoint, `:file_service`
    #
    # @return [Endpoint] the endpoint that was removed
    #
    def remove_endpoint(endpoint_id)
      endpoints.delete(endpoint_id)
    end
    alias remove remove_endpoint

    #
    # Fetches an endpoint from the collection
    #
    # @param [<type>] endpoint_id <description>
    #
    # @return [Endpoint]
    #
    def find_endpoint(endpoint_id)
      endpoints[endpoint_id]
    end
    alias find find_endpoint

    #
    # Fetches an endpoint from the collection or raises an error
    #
    # @param [Symbol] endpoint_id the id of the endpoint
    #
    # @raise [EndpointNotFound] when an endpoint couldn't be found
    #
    # @return [Endpoint, nil]
    #
    def find_endpoint!(endpoint_id)
      find_endpoint(endpoint_id) || raise(EndpointNotFound, "Couldn't find an endpoint with id=:#{endpoint_id}")
    end
    alias find! find_endpoint!

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

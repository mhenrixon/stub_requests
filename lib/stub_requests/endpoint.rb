# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Endpoint provides registration of stubbed endpoints
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Endpoint
    extend Forwardable

    include Comparable
    include Property
    #
    # @!attribute [rw] id
    #   @return [Symbol] the id of the endpoint
    property :id, type: Symbol
    #
    # @!attribute [rw] verb
    #   @return [Symbol] a HTTP verb
    property :verb, type: Symbol
    #
    # @!attribute [rw] path
    #   @return [String] a string template for the endpoint
    property :path, type: String

    #
    # @!attribute [rw] service
    #   @see
    #   @return [Service] a service
    attr_reader :service

    #
    # @!attribute [rw] service_id
    #   @see
    #   @return [Symbol] the id of the service
    attr_reader :service_id

    #
    # @!attribute [rw] service_uri
    #   @see
    #   @return [String] a service's base URI
    attr_reader :service_uri

    #
    # @!attribute [rw] options
    #   @see
    #   @return [Array<Symbol>] an array with required route params
    attr_reader :route_params

    #
    # An endpoint for a specific {StubRequests::Service}
    #
    # @param [Symbol] endpoint_id a descriptive id for the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] path how to reach the endpoint
    #
    def initialize(service, endpoint_id, verb, path)
      self.id   = endpoint_id
      self.verb = verb
      self.path = path

      @service      = service
      @service_id   = service.id
      @service_uri  = service.uri
      @route_params = URI.route_params(path)
    end

    #
    # Updates this endpoint
    #
    # @param [Symbol] verb a HTTP verb
    # @param [String] path how to reach the endpoint
    # @param [optional, Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request for request_stub.with
    # @option options [optional, Hash<Symbol>] :response for request_stub.to_return
    # @option options [optional, Array, Exception, StandardError, String] :error for request_stub.to_raise
    # @option options [optional, TrueClass] :timeout for request_stub.to_timeout
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(verb, path)
      self.verb            = verb
      self.path    = path
      self
    end

    def <=>(other)
      service_id <=> other.service_id &&
        id <=> other.id
    end

    def hash
      [id, self.class].hash
    end

    alias eql? ==

    #
    # Returns a descriptive string of this endpoint
    #
    # @return [String]
    #
    def to_s
      "#<#{self.class} id=:#{id} verb=:#{verb} path='#{path}'>"
    end
  end
end

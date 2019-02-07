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
    # includes "Comparable"
    # @!parse include Comparable
    include Comparable
    # includes "Concerns::Property"
    # @!parse include Concerns::Property
    include Concerns::Property
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
    # @!attribute [rw] uri
    #   @return [String] the full uri for the endpoint
    attr_reader :uri
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
    # @!attribute [rw] route_params
    #   @see
    #   @return [Array<Symbol>] an array with required route params
    attr_reader :route_params

    #
    # Initialize an endpoint for a specific {Service}
    #
    #
    # @param [Symbol] endpoint_id a descriptive id for the endpoint
    # @param [Symbol] service_id the id of a registered service
    # @param [String] service_uri the uri of a registered service
    # @param [Symbol] verb a HTTP verb
    # @param [String] path how to reach the endpoint
    #
    def initialize(endpoint_id:, service_id:, service_uri:, verb:, path:)
      self.id       = endpoint_id
      self.verb     = verb
      self.path     = path

      @service_id   = service_id
      @service_uri  = service_uri
      @uri          = URI.safe_join(service_uri, path)
      @route_params = URI.route_params(path)
      @stubs        = Concurrent::Array.new
    end

    #
    # Updates this endpoint
    #
    #
    # @param [Symbol] verb a HTTP verb
    # @param [String] path how to reach the endpoint
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(verb, path)
      @verb = verb
      @path = path
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

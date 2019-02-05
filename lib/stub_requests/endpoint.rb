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
    property :service, type: StubRequests::Service
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
    # @!attribute [rw] options
    #   @see
    #   @return [Hash<Symbol>] a Hash with default request/response options
    property :options, type: Hash, default: {}

    attr_reader :route_params
    attr_reader :keyword_args

    #
    # An endpoint for a specific {StubRequests::Service}
    #
    # @param [Symbol] endpoint_id a descriptive id for the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] path how to reach the endpoint
    # @param [optional, Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request for request_stub.with
    # @option options [optional, Hash<Symbol>] :response for request_stub.to_return
    # @option options [optional, Array, Exception, StandardError, String] :error for request_stub.to_raise
    # @option options [optional, TrueClass] :timeout for request_stub.to_timeout
    #
    def initialize(service, endpoint_id, verb, path, options = {})
      @service     = service
      self.id      = endpoint_id
      self.verb    = verb
      self.path    = path
      self.options = options
      @route_params = StubRequests::URI.route_params(path)
    end

    #
    # The full uri for this template
    #
    #
    # @return [String] `"http://domain.dom/blog/index.html"`
    #
    def uri
      @uri ||= URI.safe_join(service.uri, endpoint.path)
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
    # @return [Registration::Endpoint] returns the updated endpoint
    #
    def update(verb, path, options)
      self.verb = verb
      self.path    = path
      self.options = options
      self
    end

    def <=>(other)
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

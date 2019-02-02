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
    include Comparable
    include Properties

    #
    # @!attribute [rw] id
    #   @return [Symbol] the id of the endpoint
    property :id, type: Symbol

    #
    # @!attribute [rw] verb
    #   @return [Symbol] a HTTP verb
    property :verb, type: Symbol

    #
    # @!attribute [rw] uri_template
    #   @return [String] a string template for the endpoint
    property :uri_template, type: String

    #
    # @!attribute [rw] options
    #   @see
    #   @return [Hash<Symbol>] a Hash with default request/response options
    property :options, type: Hash, default: {}

    #
    # An endpoint for a specific {Service}
    #
    # @param [Symbol] endpoint_id a descriptive id for the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request for request_stub.with
    # @option options [optional, Hash<Symbol>] :response for request_stub.to_return
    # @option options [optional, Array, Exception, StandardError, String] :error for request_stub.to_raise
    # @option options [optional, TrueClass] :timeout for request_stub.to_timeout
    #
    def initialize(endpoint_id, verb, uri_template, options = {})
      self.id              = endpoint_id
      self.verb            = verb
      self.uri_template    = uri_template
      self.options         = options
    end

    #
    # Updates this endpoint
    #
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request for request_stub.with
    # @option options [optional, Hash<Symbol>] :response for request_stub.to_return
    # @option options [optional, Array, Exception, StandardError, String] :error for request_stub.to_raise
    # @option options [optional, TrueClass] :timeout for request_stub.to_timeout
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(verb, uri_template, options)
      self.verb            = verb
      self.uri_template    = uri_template
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
      "#<#{self.class} id=:#{id} verb=:#{verb} uri_template='#{uri_template}'>"
    end
  end
end

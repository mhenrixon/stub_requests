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
    include ArgumentValidation
    include Comparable

    #
    # @!attribute [rw] id
    #   @return [Symbol] the id of the endpoint
    attr_reader :id

    #
    # @!attribute [rw] verb
    #   @return [Symbol] a HTTP verb
    attr_reader :verb

    #
    # @!attribute [rw] uri_template
    #   @return [String] a string template for the endpoint
    attr_reader :uri_template

    #
    # @!attribute [rw] default_options
    #   @see
    #   @return [Hash<Symbol>] a string template for the endpoint
    attr_reader :default_options

    #
    # An endpoint for a specific {Service}
    #
    # @param [Symbol] endpoint_id a descriptive id for the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] default_options
    # @option default_options [optional, Hash<Symbol>] :request for request_stub.with
    # @option default_options [optional, Hash<Symbol>] :response for request_stub.to_return
    # @option default_options [optional, Array, Exception, StandardError, String] :error for request_stub.to_raise
    # @option default_options [optional, TrueClass] :timeout for request_stub.to_timeout
    #
    def initialize(endpoint_id, verb, uri_template, default_options = {})
      validate! endpoint_id,  is_a: Symbol
      validate! verb,         is_a: Symbol
      validate! uri_template, is_a: String

      @id              = endpoint_id
      @verb            = verb
      @uri_template    = uri_template
      @default_options = default_options
    end

    #
    # Updates this endpoint
    #
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] default_options
    # @option default_options [optional, Hash<Symbol>] :request for request_stub.with
    # @option default_options [optional, Hash<Symbol>] :response for request_stub.to_return
    # @option default_options [optional, Array, Exception, StandardError, String] :error for request_stub.to_raise
    # @option default_options [optional, TrueClass] :timeout for request_stub.to_timeout
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(verb, uri_template, default_options)
      @verb            = verb
      @uri_template    = uri_template
      @default_options = default_options
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

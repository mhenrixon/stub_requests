# frozen_string_literal: true

module StubRequests
  #
  # Class Endpoint provides registration of stubbed endpoints
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class Endpoint
    #
    # @!attribute [rw] id
    #   @return [Symbol] the id of the endpoint
    attr_accessor :id

    #
    # @!attribute [rw] verb
    #   @return [Symbol] a HTTP verb
    attr_accessor :verb

    #
    # @!attribute [rw] uri_template
    #   @return [String] a string template for the endpoint
    attr_accessor :uri_template

    #
    # @!attribute [rw] default_options
    #   @see
    #   @return [Hash<Symbol>] a string template for the endpoint
    attr_accessor :default_options

    #
    # An endpoint for a specific {Service}
    #
    # @param [Symbol] endpoint_id a descriptive id for the endpoint
    # @param [Symbol] verb a HTTP verb
    # @param [String] uri_template how to reach the endpoint
    # @param [optional, Hash<Symbol>] default_options
    # @option default_options [optional, Hash<Symbol>] :request see {API.prepare_request}
    # @option default_options [optional, Hash<Symbol>] :response see {API.prepare_response}
    # @option default_options [optional, Array, Exception, StandardError, String] :error see {#API.prepare_error}
    # @option default_options [optional, TrueClass] :timeout if the stubbed request should raise Timeout
    #
    def initialize(endpoint_id, verb, uri_template, default_options = {})
      # TODO: Validate endpoint_id, verb and uri_template
      # TODO: Implement default options

      # validate! endpoint_id,  is: Symbol, allow_nil: false
      # validate! verb,         is: Symbol, allow_nil: false
      # validate! uri_template, is: String, allow_nil: false

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
    # @option default_options [optional, Hash<Symbol>] :request see {API.prepare_request}
    # @option default_options [optional, Hash<Symbol>] :response see {API.prepare_response}
    # @option default_options [optional, Array, Exception, StandardError, String] :error see {#API.prepare_error}
    # @option default_options [optional, TrueClass] :timeout if the stubbed request should raise Timeout
    #
    # @return [Endpoint] returns the updated endpoint
    #
    def update(verb, uri_template, default_options)
      @verb            = verb
      @uri_template    = uri_template
      @default_options = default_options
      self
    end

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

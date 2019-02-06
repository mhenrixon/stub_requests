# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Registry handles callbacks to webmock requests
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.3
  #
  class CallbackRegistry
    include Singleton
    include Enumerable

    #
    # Register to a service endpoint call
    # @see CallbackRegistry#register
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    # @param [Proc] callback the callback to use for when.a request was made
    #
    # @return [Callback]
    #
    def self.register(service_id, endpoint_id, verb, callback)
      instance.register(service_id, endpoint_id, verb, callback)
    end

    #
    # Unregister from a service endpoint call
    # @see CallbackRegistry#unregister
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Callback]
    #
    def self.unregister(service_id, endpoint_id, verb)
      instance.unregister(service_id, endpoint_id, verb)
    end

    #
    # Notifies subscribers that a request was made
    # @see CallbackRegistry#invoke_callbacks
    #
    #
    # @param [RequestStub] request the stubbed request
    #
    # @return [RequestStub]
    #
    def self.invoke_callbacks(request)
      instance.invoke_callbacks(request)
    end

    #
    # @!attribute [r] callbacks
    #   @return [Concurrent::Array<Callback>] a list of callbacks
    attr_reader :callbacks

    #
    # Used by Singleton
    #
    #
    def initialize
      @callbacks = Concurrent::Array.new
    end

    #
    # Resets the map with registered services
    #
    #
    # @api private
    def reset
      callbacks.clear
    end

    #
    # Required by Enumerable
    #
    #
    # @return [Concurrent::Array<Callback>] a list with callbacks
    #
    # @yield used by Enumerable
    #
    def each(&block)
      callbacks.each(&block)
    end

    #
    # Register to a service endpoint call
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [optional, Symbol] verb the HTTP verb to subscribe to
    # @param [proc] block the callback to use for when.a request was made
    #
    # @return [Callback] the added callback
    #
    def register(service_id, endpoint_id, verb, block)
      callback = find_by(service_id, endpoint_id, verb)
      return callback if callback

      callback = Callback.new(service_id, endpoint_id, verb, block)
      callbacks.push(callback)
      callback
    end

    #
    # Unregister to a service endpoint call
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [optional, Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Callback] the deleted callback
    #
    def unregister(service_id, endpoint_id, verb)
      return unless (callback = find_by(service_id, endpoint_id, verb))

      callbacks.delete(callback)
    end

    #
    # Notifies subscribers that a request was made
    #
    # @param [RequestStub] request_stub the stubbed request
    #
    # @return [void]
    #
    def invoke_callbacks(request_stub)
      return unless (callback = find_by(request_stub.service_id, request_stub.endpoint_id, request_stub.verb))

      callback.call(request_stub)
    end

    private

    #
    # Finds a callback for a service endpoint
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [optional, Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Callback]
    #
    def find_by(service_id, endpoint_id, verb)
      find do |sub|
        sub.service_id == service_id &&
          sub.endpoint_id == endpoint_id &&
          ([sub.verb, verb].include?(:any) || sub.verb == verb)
      end
    end
  end
end

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
  # :reek:UtilityFunction
  # :reek:DataClump
  # :reek:FeatureEnvy
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
    # :reek:LongParameterList
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
    # @param [proc] callback the callback to use for when.a request was made
    #
    # @return [Callback] the added callback
    #
    # :reek:LongParameterList
    def register(service_id, endpoint_id, verb, callback)
      registered_callback = find_by(service_id, endpoint_id, verb)
      return registered_callback if registered_callback

      registered_callback = Callback.new(service_id, endpoint_id, verb, callback)
      callbacks.push(registered_callback)
      registered_callback
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
    # :reek:ControlParameter
    def unregister(service_id, endpoint_id, verb)
      return unless (callback = find_by(service_id, endpoint_id, verb))

      callbacks.delete(callback)
    end

    #
    # Notifies subscribers that a request was made
    #
    # @param [RequestStub] request the stubbed request
    #
    # @return [void]
    #
    def invoke_callbacks(request)
      return unless (callback = find_by(request.service_id, request.endpoint_id, request.verb))

      dispatch_callback(request, callback)
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
    # :reek:ControlParameter
    # :reek:DuplicateMethodCall
    def find_by(service_id, endpoint_id, verb)
      find do |sub|
        sub.service_id == service_id &&
          sub.endpoint_id == endpoint_id &&
          ([sub.verb, verb].include?(:any) || sub.verb == verb)
      end
    end

    def dispatch_callback(request, callback)
      callback = callback.callback
      arity    = callback.arity

      case arity
      when 0
        callback.call
      when 1
        callback.call(request)
      else
        raise InvalidCallback, "The callback for a callback can either take 0 or 1 arguments (was #{arity})"
      end
    end
  end
end

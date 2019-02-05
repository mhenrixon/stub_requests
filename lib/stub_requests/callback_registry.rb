# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Registry handles subscriptions to webmock requests
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
    # Subscribe to a service endpoint call
    # @see CallbackRegistry#subscribe
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
    def self.subscribe_to(service_id, endpoint_id, verb, callback)
      instance.subscribe(service_id, endpoint_id, verb, callback)
    end

    #
    # Unsubscribe from a service endpoint call
    # @see CallbackRegistry#unsubscribe
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Callback]
    #
    def self.unsubscribe_from(service_id, endpoint_id, verb)
      instance.unsubscribe(service_id, endpoint_id, verb)
    end

    #
    # Notifies subscribers that a request was made
    # @see CallbackRegistry#notify_subscribers
    #
    #
    # @param [Metrics::Request] request the stubbed request
    #
    # @return [Request]
    #
    def self.notify_subscribers(request)
      instance.notify_subscribers(request)
    end


    #
    # @!attribute [r] subscriptions
    #   @return [Concurrent::Array<Callback>] a list of subscriptions
    attr_reader :subscriptions

    #
    # Used by Singleton
    #
    #
    def initialize
      @subscriptions = Concurrent::Array.new
    end

    #
    # Resets the map with registered services
    #
    #
    # @api private
    def reset
      subscriptions.clear
    end

    #
    # Required by Enumerable
    #
    #
    # @return [Concurrent::Array<Callback>] a list with subscriptions
    #
    # @yield used by Enumerable
    #
    def each(&block)
      subscriptions.each(&block)
    end

    #
    # Subscribe to a service endpoint call
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [optional, Symbol] verb the HTTP verb to subscribe to
    # @param [proc] callback the callback to use for when.a request was made
    #
    # @return [Callback] the added subscription
    #
    # :reek:LongParameterList
    def subscribe(service_id, endpoint_id, verb, callback)
      subscription = find_by(service_id, endpoint_id, verb)
      return subscription if subscription

      subscription = Callback.new(service_id, endpoint_id, verb, callback)
      subscriptions.push(subscription)
      subscription
    end

    #
    # Unsubscribe to a service endpoint call
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [optional, Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Callback] the deleted subscription
    #
    # :reek:ControlParameter
    def unsubscribe(service_id, endpoint_id, verb)
      return unless (subscription = find_by(service_id, endpoint_id, verb))

      subscriptions.delete(subscription)
    end

    #
    # Notifies subscribers that a request was made
    #
    # @param [Metrics::Request] request the stubbed request
    #
    # @return [void]
    #
    def notify_subscribers(request)
      return unless (subscription = find_by(request.service_id, request.endpoint_id, request.verb))

      send_notification(request, subscription)
    end

    private

    #
    # Finds a subscription for a service endpoint
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

    def send_notification(request, subscription)
      callback = subscription.callback
      arity    = callback.arity

      case arity
      when 0
        callback.call
      when 1
        callback.call(request)
      else
        raise InvalidCallback, "The callback for a subscription can either take 0 or 1 arguments (was #{arity})"
      end
    end
  end
end

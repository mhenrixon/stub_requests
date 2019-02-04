# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Observable handles listening to endpoint invocations
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.3
  #
  module Observable
    #
    # Class Registry handles subscriptions to webmock requests
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.3
    #
    # :reek:UtilityFunction
    # :reek:DataClump
    # :reek:FeatureEnvy
    class Registry
      include Singleton
      include Enumerable

      #
      # @!attribute [r] subscriptions
      #   @return [Concurrent::Array<Subscription>] a list of subscriptions
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
      # @return [Concurrent::Array<Subscription>] a list with subscriptions
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
      # @return [Subscription] the added subscription
      #
      # :reek:LongParameterList
      def subscribe(service_id, endpoint_id, verb, callback)
        subscription = find_by(service_id, endpoint_id, verb)
        return subscription if subscription

        subscription = Subscription.new(service_id, endpoint_id, verb, callback)
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
      # @return [Subscription] the deleted subscription
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
      # @return [Subscription]
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
end

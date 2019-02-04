# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class SubscriptionRegistry handles subscriptions to webmock requests
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.3
  #
  # :reek:UtilityFunction
  # :reek:DataClump
  # :reek:FeatureEnvy
  class SubscriptionRegistry
    include Singleton
    include Enumerable

    #
    # @!attribute [r] subscriptions
    #   @return [Concurrent::Array<Subscription>] a list of subscriptions
    attr_reader :subscriptions

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
    # Used by Singleton
    #
    #
    def initialize
      @subscriptions = Concurrent::Array.new
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
    def unsubscribe(service_id, endpoint_id, verb = :any)
      delete do |sub|
        sub.service_id == service_id &&
          sub.endpoint_id == endpoint_id &&
          sub.verb == verb
      end
    end

    #
    # Finds a subscription for a service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [optional, Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Subscription]
    #
    # :reek:ControlParameter
    def find_by(service_id, endpoint_id, verb)
      find do |sub|
        sub.service_id == service_id &&
          sub.endpoint_id == endpoint_id &&
          ([sub.verb, verb].include?(:any) || sub.verb == verb)
      end
    end

    # @api private
    # :reek:FeatureEnvy
    # :reek:DuplicateMethodCall
    def notify(obj)
      return unless (subscription = find_by(obj.service_id, obj.endpoint_id, obj.verb))

      p "The service :#{obj.service_id} just received :#{obj.verb} to endpoint :#{obj.endpoint_id}."
      p "The full URI was #{obj.uri}"
      subscription.callback.call(obj)
    end
  end
end

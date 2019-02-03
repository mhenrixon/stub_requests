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

    # @api private
    class Subscription
      include Property
      property :service_id, type: Symbol
      property :endpoint_id, type: Symbol
      property :verb, type: Symbol, default: :any
      property :callback, type: Proc

      def initialize(service_id, endpoint_id, verb, callback)
        self.service_id  = service_id
        self.endpoint_id = endpoint_id
        self.verb        = verb
        self.callback    = callback
      end
    end

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
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Subscription] the added subscription
    #
    def subscribe(service_id, endpoint_id, verb = :any, callback)
      subscription = find_by(service_id, endpoint_id, verb)
      return subscription if subscription

      subscription = Subscription.new(service_id, endpoint_id, verb, callback)
      subscriptions.push(subscription)
      subscription
    end

    #
    # Finds a subscription for a service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Subscription]
    #
    # :reek:ControlParameter
    def find_by(service_id, endpoint_id, verb = :any)
      find do |sub|
        sub.service_id == service_id &&
          sub.endpoint_id == endpoint_id &&
          ([sub.verb, verb].include?(:any) || sub.verb == :any || sub.verb == verb)
      end
    end

    #
    # Checks if a subscription exists to the service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to unsubscribe from
    #
    # @return [true, false]
    #
    def subscribed?(service_id, endpoint_id, _verb = :any)
      !!find_by(service_id, endpoint_id, verb) # rubocop:disable Style/DoubleNegation
    end

    # @api private
    # :reek:FeatureEnvy
    # :reek:DuplicateMethodCall
    def notify(obj)
      return unless (subscription = find_by(obj.service_id, obj.endpoint_id, obj.verb))

      p "The service :#{obj.service_id} just received :#{obj.verb} to endpoint :#{obj.endpoint_id}."
      p "The full URI was #{obj.uri}"
      Docile.dsl_eval(obj, &subscription.callback)
    end
  end
end

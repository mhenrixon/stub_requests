# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Observable handles observing webmock requests
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.3
  #
  module Observable
    #
    # Subscribe to a service endpoint call
    # @see Observable::Registry#subscribe
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    # @param [proc] callback the callback to use for when.a request was made
    #
    # @return [Subscription]
    #
    # :reek:LongParameterList
    def self.subscribe_to(service_id, endpoint_id, verb, callback)
      Registry.instance.subscribe(service_id, endpoint_id, verb, callback)
    end

    #
    # Unsubscribe from a service endpoint call
    # @see Observable::Registry#unsubscribe
    #
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb to subscribe to
    #
    # @return [Subscription]
    #
    def self.unsubscribe_from(service_id, endpoint_id, verb)
      Registry.instance.unsubscribe(service_id, endpoint_id, verb)
    end

    #
    # Notifies subscribers that a request was made
    # @see Observable::Registry#notify_subscribers
    #
    #
    # @param [Metrics::Request] request the stubbed request
    #
    # @return [Request]
    #
    def self.notify_subscribers(request_stub)
      Registry.instance.notify_subscribers(request_stub)
    end
  end
end

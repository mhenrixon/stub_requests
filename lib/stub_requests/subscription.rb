# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Subscription contains information about a subscription
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.3
  #
  class Subscription
    include Property
    #
    # @!attribute [rw] service_id
    #   @return [Symbol] the id of a service
    property :service_id, type: Symbol
    #
    # @!attribute [rw] endpoint_id
    #   @return [Symbol] the id of an endpoint
    property :endpoint_id, type: Symbol
    #
    # @!attribute [rw] verb
    #   @return [Symbol] the HTTP verb/method
    property :verb, type: Symbol, default: :any
    #
    # @!attribute [rw] callback
    #   @return [Proc] a proc to callback on notify
    property :callback, type: Proc

    #
    # Initialize a new Subscription
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb the HTTP verb/method
    # @param [Proc] callback a proc to callback on notify
    #
    def initialize(service_id, endpoint_id, verb, callback)
      self.service_id  = service_id
      self.endpoint_id = endpoint_id
      self.verb        = verb
      self.callback    = callback
    end
  end
end

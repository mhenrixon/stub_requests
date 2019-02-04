# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Metrics contains logic for collecting metrics about requests stubs
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module Metrics
    #
    # Class Stub tracks the WebMock::RequestStub life cycle
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    # :reek:TooManyInstanceVariables
    class Request
      include Property
      extend Forwardable

      # Delegate service_id, endpoint_id, verb and uri_template to endpoint
      delegate [:service_id, :endpoint_id, :verb, :uri_template] => :endpoint
      #
      # @!attribute [r] endpoint
      #   @return [StubRequests::Metrics::Endpoint] a stubbed endpoint
      property :endpoint, type: StubRequests::Metrics::Endpoint
      #
      # @!attribute [r] verb
      #   @return [Symbol] a HTTP verb/method
      property :verb, type: Symbol
      #
      # @!attribute [r] uri
      #   @return [String] the full URI for this endpoint
      property :uri, type: String
      #
      # @!attribute [r] request_stub
      #   @return [WebMock::RequestStub] a webmock stubbed request
      property :request_stub, type: WebMock::RequestStub
      #
      # @!attribute [r] recorded_at
      #   @return [Time] the time this record was recorded
      property :recorded_at, type: Time
      #
      # @!attribute [r] recorded_from
      #   @return [String] the relative path to the spec that recorded it
      property :recorded_from, type: String
      #
      # @!attribute [r] responded_at
      #   @return [Time] the time this stubs response was used
      property :responded_at, type: Time

      #
      # Initialize a new Record
      #
      #
      # @param [Endpoint] endpoint a stubbed endpoint
      # @param [WebMock::RequestStub] request_stub the stubbed webmock request
      #
      def initialize(endpoint, request_stub)
        request_pattern = request_stub.request_pattern
        @endpoint       = endpoint
        @verb           = request_pattern.method_pattern.to_s.to_sym
        @uri            = request_pattern.uri_pattern.to_s
        @request_stub   = request_stub
        @recorded_at    = Time.now
        @recorded_from  = RSpec.current_example.metadata[:location]
        @responded_at   = nil
      end

      #
      # Marks this record as having responded
      #
      #
      # @return [Time] the time it was marked responded
      #
      def mark_as_responded
        @responded_at = Time.now
        Observable.notify_subscribers(self)
      end
    end
  end
end
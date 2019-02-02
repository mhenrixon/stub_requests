# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Metrics contains logic for collecting metrics about {EndpointStat} and {StubStat}
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module Metrics
    #
    # Class StubStat tracks the WebMock::RequestStub life cycle
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    # :reek:TooManyInstanceVariables
    class StubStat
      #
      # @!attribute [r] verb
      #   @return [Symbol] a HTTP verb/method
      attr_reader :verb
      #
      # @!attribute [r] uri
      #   @return [String] the full URI for this endpoint
      attr_reader :uri
      #
      # @!attribute [r] request_stub
      #   @return [WebMock::RequestStub] a webmock stubbed request
      attr_reader :request_stub
      #
      # @!attribute [r] recorded_at
      #   @return [Time] the time this record was recorded
      attr_reader :recorded_at
      #
      # @!attribute [r] recorded_from
      #   @return [String] the relative path to the spec that recorded it
      attr_reader :recorded_from
      #
      # @!attribute [r] responded_at
      #   @return [Time] the time this stubs response was used
      attr_reader :responded_at

      #
      # Initialize a new Record
      #
      #
      # @param [EndpointStat] endpoint_stat a stubbed endpoint
      # @param [WebMock::RequestStub] request_stub the stubbed webmock request
      #
      def initialize(endpoint_stat, request_stub)
        request_pattern = request_stub.request_pattern
        @endpoint_stat  = endpoint_stat
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
      end
    end
  end
end

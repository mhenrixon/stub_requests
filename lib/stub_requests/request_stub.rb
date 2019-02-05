# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Stub tracks the WebMock::RequestStub life cycle
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  # :reek:TooManyInstanceVariables
  class RequestStub
    include Property
    extend Forwardable

    # Delegate service_id, endpoint_id, verb and path to endpoint_stub
    delegate [:service_id, :endpoint_id, :verb, :path] => :endpoint_stub
    #
    # @!attribute [r] endpoint
    #   @return [EndpointStub] a stubbed endpoint
    property :endpoint_stub, type: StubRequests::EndpointStub
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
    # @param [EndpointStub] endpoint_stub a stubbed endpoint
    # @param [WebMock::RequestStub] request_stub the stubbed webmock request
    #
    def initialize(endpoint_stub, request_stub)
      request_pattern     = request_stub.request_pattern
      self.endpoint_stub  = endpoint_stub
      self.verb           = request_pattern.method_pattern.to_s.to_sym
      self.uri            = request_pattern.uri_pattern.to_s
      self.request_stub   = request_stub
      self.recorded_at    = Time.now
      self.recorded_from  = RSpec.current_example.metadata[:location]
      @responded_at = nil # ByPass the validation for the initializer
    end

    #
    # Marks this record as having responded
    #
    #
    # @return [Time] the time it was marked responded
    #
    def mark_as_responded
      self.responded_at = Time.now
      Observable.notify_subscribers(self)
    end
  end
end

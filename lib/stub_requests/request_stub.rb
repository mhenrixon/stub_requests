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
  class RequestStub
    # extends "Forwardable"
    # @!parse extend Forwardable
    extend Forwardable

    # includes "Concerns::Property"
    # @!parse include Concerns::Property
    include Concerns::Property

    # Delegate service_id, endpoint_id, verb and path to endpoint
    delegate [:service_id, :service_uri, :verb, :path] => :endpoint
    #
    # @!attribute [r] endpoint
    #   @return [Symbol] the id of a registered {Endpoint}
    property :endpoint_id, type: Symbol
    #
    # @!attribute [r] verb
    #   @return [Symbol] a HTTP verb/method
    property :verb, type: Symbol
    #
    # @!attribute [r] uri
    #   @return [String] the full URI for this endpoint
    property :request_uri, type: String
    #
    # @!attribute [r] webmock_stub
    #   @return [WebMock::RequestStub] a webmock stubbed request
    property :webmock_stub, type: WebMock::RequestStub
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
    # @param [Endpoint] endpoint_id the id of a stubbed endpoint
    # @param [WebMock::RequestStub] webmock_stub the stubbed webmock request
    #
    def initialize(endpoint_id, webmock_stub)
      request_pattern     = webmock_stub.request_pattern
      self.endpoint_id    = endpoint_id
      self.verb           = request_pattern.method_pattern.to_s.to_sym
      self.request_uri    = request_pattern.uri_pattern.to_s
      self.webmock_stub   = webmock_stub
      self.recorded_at    = Time.now
      self.recorded_from  = RSpec.current_example.metadata[:location]
      @responded_at = nil # ByPass the validation for the initializer
    end

    #
    # Retrieve the endpoint for this request stub
    #
    #
    # @return [Endpoint] <description>
    #
    def endpoint
      EndpointRegistry.instance[endpoint_id]
    end

    #
    # Marks this record as having responded
    #
    #
    # @return [Time] the time it was marked responded
    #
    def mark_as_responded
      self.responded_at = Time.now
    end
  end
end

# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Registry maintains a registry of stubbed endpoints.
  #   Also allows provides querying capabilities for said entities.
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  class StubRegistry
    # extend "Forwardable"
    # @!parse extend Forwardable
    extend Forwardable

    # includes "Singleton"
    # @!parse include Singleton
    include Singleton
    # includes "Enumerable"
    # @!parse include Enumerable
    include Enumerable

    delegate [:each, :concat] => :stubs

    #
    # @!attribute [r] stubs
    #   @return [Concurrent::Array] a collection of {RequestStub}
    attr_reader :stubs

    #
    # Initialize a new registry
    #
    #
    def initialize
      reset
    end

    #
    # Resets the map with stubbed endpoints
    #
    #
    # @api private
    def reset
      @stubs = Concurrent::Array.new
    end

    #
    # Records a WebMock::RequestStub as stubbed
    #
    # @param [WebMock::RequestStub] webmock_stub <description>
    #
    # @return [RequestStub]
    #
    def record(endpoint_id, webmock_stub)
      return unless StubRequests.config.record_stubs?

      request_stub = RequestStub.new(endpoint_id, webmock_stub)
      concat([request_stub])
      request_stub
    end

    #
    # Mark a {RequestStub} as having responded
    #
    # @note Called when webmock responds successfully
    #
    # @param [WebMock::RequestStub] webmock_stub the stubbed webmock request
    #
    # @return [void]
    #
    def mark_as_responded(webmock_stub)
      return unless (request_stub = find_by_webmock_stub(webmock_stub))

      request_stub.mark_as_responded
      CallbackRegistry.instance.invoke_callbacks(request_stub)
      request_stub
    end

    #
    # Finds a {RequestStub} amongst the endpoint stubs
    #
    #
    # @param [WebMock::RequestStub] webmock_stub a stubbed webmock response
    #
    # @return [RequestStub] the request_stubbed matching the request stub
    #
    def find_by_webmock_stub(webmock_stub)
      find { |stub| stub.webmock_stub == webmock_stub }
    end
  end
end

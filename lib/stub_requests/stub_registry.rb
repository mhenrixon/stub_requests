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
  # :reek:DataClump
  class StubRegistry
    # includes "Singleton"
    # @!parse include Singleton
    include Singleton
    # includes "Enumerable"
    # @!parse include Enumerable
    include Enumerable

    #
    # Records metrics about stubbed endpoints
    #
    #
    # @param [Service] service a Service
    # @param [Endpoint] endpoint an Endpoint
    # @param [WebMock::RequestStub] webmock_stub the stubbed webmock request
    #
    # @note the class method of record validates that
    #   configuration option :collect_metrics is true.
    #
    # @return [EndpointStub] the stub that was recorded
    #
    def self.record(service, endpoint, webmock_stub)
      # Note: The class method v
      return unless StubRequests.config.record_metrics?

      instance.record(service, endpoint, webmock_stub)
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
    def self.mark_as_responded(webmock_stub)
      instance.mark_as_responded(webmock_stub)
    end

    #
    # @!attribute [rw] services
    #   @return [Concurrent::Array<Endpoint>] a map with stubbed endpoints
    attr_reader :endpoints

    #
    # Initialize a new registry
    #
    #
    def initialize
      @endpoints = Concurrent::Array.new
    end

    #
    # Resets the map with stubbed endpoints
    #
    #
    # @api private
    def reset
      endpoints.clear
    end

    #
    # Required by Enumerable
    #
    #
    # @return [Concurrent::Array<Endpoint>] an array with stubbed endpoints
    #
    # @yield used by Enumerable
    #
    def each(&block)
      endpoints.each(&block)
    end

    #
    # Records metrics about stubbed endpoints
    #
    #
    # @param [Service] service a symbolic id of the service
    # @param [Endpoint] endpoint a string with a base_uri to the service
    # @param [WebMock::RequestStub] webmock_stub the stubbed request
    #
    # @return [Service] the service that was just registered
    #
    def record(service, endpoint, webmock_stub)
      endpoint = find_or_initialize_endpoint_stub(service, endpoint)
      endpoint.record(webmock_stub)

      endpoints.push(endpoint)
      endpoint
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
      return unless (request_stub = find_request_stub(webmock_stub))

      request_stub.mark_as_responded
      CallbackRegistry.invoke_callbacks(request_stub)
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
    def find_request_stub(webmock_stub)
      map do |endpoint|
        endpoint.find_by(attribute: :request_stub, value: webmock_stub)
      end.compact.first
    end

    private

    def find_or_initialize_endpoint_stub(service, endpoint)
      find_endpoint_stub(service, endpoint) || initialize_endpoint_stub(service, endpoint)
    end

    # :reek:UtilityFunction
    # :reek:FeatureEnvy
    def find_endpoint_stub(service, endpoint)
      find { |ep| ep.service_id == service.id && ep.endpoint_id == endpoint.id }
    end

    # :reek:UtilityFunction
    def initialize_endpoint_stub(service, endpoint)
      EndpointStub.new(service, endpoint)
    end
  end
end

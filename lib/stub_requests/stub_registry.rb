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
    # includes "Singleton"
    # @!parse include Singleton
    include Singleton
    # includes "Enumerable"
    # @!parse include Enumerable
    include Enumerable

    #
    # @!attribute [rw] services
    #   @return [Concurrent::Array<Endpoint>] a map with stubbed endpoints
    attr_reader :endpoint_stubs

    #
    # Initialize a new registry
    #
    #
    def initialize
      @endpoints = Concurrent::Map.new
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

    def stub_endpoint(service_id, endpoint_id, route_params = {})
      service, endpoint, uri = StubRequests::URI.for_service_endpoint(service_id, endpoint_id, route_params)
      request_stub           = WebMock::Builder.build(endpoint.verb, uri, options, &callback)
      endpoint_stub          = find_or_initialize_stub(service, endpoint)

      endpoint_stubs.push(endpoint_stub)
      ::WebMock::StubRegistry.instance.register_request_stub(request_stub)
    end

    #
    # Mark a {Request} as having responded
    #
    # @note Called when webmock responds successfully
    #
    # @param [WebMock::RequestStub] request_stub the stubbed webmock request
    #
    # @return [void]
    #
    def mark_as_responded(request_stub)
      return unless (request = find_request_stub(request_stub))

      request.mark_as_responded
    end

    #
    # Finds a {Request} amongst the endpoint stubs
    #
    #
    # @param [WebMock::RequestStub] request_stub a stubbed webmock response
    #
    # @return [Request] the request_stubbed matching the request stub
    #
    def find_request_stub(request_stub)
      map do |endpoint|
        endpoint.find_by(attribute: :request_stub, value: request_stub)
      end.compact.first
    end

    private

    def find_or_initialize_stub(service, endpoint)
      find_stub(service, endpoint) || initialize_stub(service, endpoint)
    end

    # :reek:UtilityFunction
    # :reek:FeatureEnvy
    def find_stub(service, endpoint)
      find { |ep| ep.service_id == service.id && ep.endpoint_id == endpoint.id }
    end

    # :reek:UtilityFunction
    def initialize_stub(service, endpoint)
      Metrics::Endpoint.new(service, endpoint)
    end
  end
end

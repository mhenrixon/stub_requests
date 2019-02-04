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
  # :reek:DataClump
  module Metrics
    #
    # Class Registry maintains a registry of stubbed endpoints.
    #   Also allows provides querying capabilities for said entities.
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    class Registry
      # includes "Singleton"
      # @!parse include Singleton
      include Singleton
      # includes "Enumerable"
      # @!parse include Enumerable
      include Enumerable

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
      # @param [StubRequests::Registration::Service] service a symbolic id of the service
      # @param [StubRequests::Registration::Endpoint] endpoint a string with a base_uri to the service
      # @param [WebMock::RequestStub] request_stub the stubbed request
      #
      # @return [Service] the service that was just registered
      #
      def record(service, endpoint, request_stub)
        endpoint = find_or_initialize_endpoint(service, endpoint)
        endpoint.record(request_stub)

        endpoints.push(endpoint)
        endpoint
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
        return unless (request = find_request(request_stub))

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
      def find_request(request_stub)
        map do |endpoint|
          endpoint.find_by(attribute: :request_stub, value: request_stub)
        end.compact.first
      end

      private

      def find_or_initialize_endpoint(service, endpoint)
        find_endpoint(service, endpoint) || initialize_endpoint(service, endpoint)
      end

      # :reek:UtilityFunction
      # :reek:FeatureEnvy
      def find_endpoint(service, endpoint)
        find { |ep| ep.service_id == service.id && ep.endpoint_id == endpoint.id }
      end

      # :reek:UtilityFunction
      def initialize_endpoint(service, endpoint)
        Metrics::Endpoint.new(service, endpoint)
      end
    end
  end
end

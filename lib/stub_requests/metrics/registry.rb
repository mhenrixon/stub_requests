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
      #   @return [Concurrent::Array<EndpointStat>] a map with stubbed endpoints
      attr_reader :stats

      #
      # Initialize a new registry
      #
      #
      def initialize
        @stats = Concurrent::Array.new
      end

      #
      # Resets the map with stubbed endpoints
      #
      #
      # @api private
      def reset
        stats.clear
      end

      #
      # Required by Enumerable
      #
      #
      # @return [Concurrent::Array<EndpointStat>] an array with stubbed endpoints
      #
      # @yield used by Enumerable
      #
      def each(&block)
        stats.each(&block)
      end

      #
      # Registers a service in the registry
      #
      #
      # @param [Service] service a symbolic id of the service
      # @param [Endpoint] endpoint a string with a base_uri to the service
      # @param [WebMock::RequestStub] request_stub the stubbed request
      #
      # @return [Service] the service that was just registered
      #
      def record_request_stub(service, endpoint, request_stub)
        stat = find_or_initialize_stat(service, endpoint)
        stat.record(request_stub)

        stats.push(stat)
        stat
      end

      def mark_as_responded(request_stub)
        return unless (stat = find_stub_stat(request_stub))

        stat.mark_as_responded
      end

      #
      # Finds a {StubStat} amongst the endpoint stubs
      #
      #
      # @param [WebMock::RequestStub] request_stub a stubbed webmock response
      #
      # @return [StubStat] the stub_stat matching the request stub
      #
      # :reek:NestedIterators
      def find_stub_stat(request_stub)
        map do |endpoint|
          endpoint.find_by(attribute: :request_stub, value: request_stub)
        end.compact.first
      end

      private

      def find_or_initialize_stat(service, endpoint)
        find_stat(service, endpoint) || initialize_stat(service, endpoint)
      end

      # :reek:UtilityFunction
      # :reek:FeatureEnvy
      def find_stat(service, endpoint)
        find { |stat| stat.service_id == service.id && stat.endpoint_id == endpoint.id }
      end

      # :reek:UtilityFunction
      def initialize_stat(service, endpoint)
        Metrics::EndpointStat.new(service, endpoint)
      end
    end
  end
end

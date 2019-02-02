# frozen_string_literal: true

require "singleton"
require "concurrent/array"

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Metrics contains logic for recording endpoint_stubs about stubs
  #
  module Metrics
    class EndpointStub
      include Enumerable

      attr_reader :service_id
      attr_reader :endpoint_id
      attr_reader :uri_template
      attr_reader :records

      def initialize(service, endpoint)
        @service_id   = service.id
        @endpoint_id  = endpoint.id
        @uri_template = [service.uri, endpoint.uri_template].join("/")
        @records = []
      end

      #
      # Required by Enumerable
      #
      #
      # @return [Concurrent::Map<Symbol, Service>] an map with services
      #
      # @yield used by Enumerable
      #
      def each(&block)
        records.each(&block)
      end

      def record(request_stub)
        records.push(Record.new(self, request_stub))
      end
    end

    class Record
      attr_reader :verb
      attr_reader :uri
      attr_reader :headers
      attr_reader :request_signature
      attr_reader :request_stub
      attr_reader :recorded_at
      attr_reader :recorded_from
      attr_reader :responded_at

      def initialize(endpoint, request_stub)
        @endpoint      = endpoint
        @verb          = request_stub.request_pattern.method_pattern.to_s.to_sym
        @uri           = request_stub.request_pattern.uri_pattern.to_s
        @request_stub  = request_stub
        @recorded_at   = Time.now
        @recorded_from = RSpec.current_example.metadata[:location]
        @responded_at  = nil
      end

      def mark_as_responded!
        @responded_at = Time.now
      end
    end

    class Registry
      include Singleton
      include Enumerable

      RECORD_BY_REQUEST_STUB = ->(recorded) { recorded.request_stub == request_stub }
      ENDPOINT_STUB_BY_REQUEST_STUB = ->(endpoint) { endpoint.find(RECORD_BY_REQUEST_STUB) }
      #
      # @!attribute [rw] services
      #   @return [Concurrent::Map<Symbol, Service>] a map with services
      attr_reader :endpoint_stubs

      def initialize
        @endpoint_stubs = Concurrent::Array.new
      end

      #
      # Resets the map with registered services
      #
      #
      # @api private
      def reset
        endpoint_stubs.clear
      end

      #
      # Required by Enumerable
      #
      #
      # @return [Concurrent::Map<Symbol, Service>] an map with services
      #
      # @yield used by Enumerable
      #
      def each(&block)
        endpoint_stubs.each(&block)
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
      def record_metric(service, endpoint, request_stub)
        # TODO: Allow this to be switched off/on via configuration
        endpoint_stub = find_or_initialize_endpoint_stub(service, endpoint)
        endpoint_stub.record(request_stub)

        endpoint_stubs.push(endpoint_stub)
      end

      def find_record(_request_stub)
        endpoint_stub = find { |endstub| endstub.find(RECORD_BY_REQUEST_STUB) }
        endpoint_stub.find(RECORD_BY_REQUEST_STUB)
      end

      def find_or_initialize_endpoint_stub(service, endpoint)
        find_endpoint_stub(service, endpoint) || initialize_endpoint_stub(service, endpoint)
      end

      def find_endpoint_stub(service, endpoint)
        endpoint_stubs.find do |endpoint_stub|
          endpoint_stub.service_id == service.id &&
            endpoint_stub.endpoint_id == endpoint.id
        end
      end

      def initialize_endpoint_stub(service, endpoint)
        Metrics::EndpointStub.new(service, endpoint)
      end
    end
  end
end

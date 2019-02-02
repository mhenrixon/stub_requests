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
  # Class ServiceRegistry provides registration of services
  #
  module Metrics
    class Endpoint
      attr_reader :service_id
      attr_reader :endpoint_id
      attr_reader :uri_template
      attr_reader :registrations

      def initialize(service, endpoint)
        @service_id   = service.id
        @endpoint_id  = endpoint.id
        @uri_template = [service.uri, endpoint.uri_template].join("/")
        @registrations = []
      end

      def record(request_stub)
        registrations.push(Recorded.new(request_stub))
      end
    end

    class Recorded
      attr_reader :uri
      attr_reader :verb
      attr_reader :body
      attr_reader :headers
      attr_reader :request_stub
      attr_reader :recorded_at
      attr_reader :recorded_from

      def initialize(request_stub)
        @recorded_from = RSpec.current_example.metadata[:location]
        @uri           = request_stub.request_pattern.uri_pattern.to_s
        @verb          = request_stub.request_pattern.method_pattern.to_s.to_sym
        @body          = request_stub.request_pattern.body_pattern.to_s.to_sym
        @headers       = request_stub.request_pattern.headers_pattern.to_s.to_sym
        @request_stub  = request_stub
        @recorded_at   = Time.now
      end
    end

    class Registry
      include Singleton
      include Enumerable

      #
      # @!attribute [rw] services
      #   @return [Concurrent::Map<Symbol, Service>] a map with services
      attr_reader :metrics

      def initialize
        @metrics = Concurrent::Array.new
      end

      #
      # Resets the map with registered services
      #
      #
      # @api private
      def reset
        metrics.clear
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
        metrics.each(&block)
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
        metric = find_or_create_endpoint(service, endpoint)
        metric.record(request_stub)
      end

      def find_or_create_endpoint(service, endpoint)
        find_metric(service, endpoint) || create_metric(service, endpoint)
      end

      def find_metric(service, endpoint)
        metrics.find do |metric|
          metric.service_id == service.id &&
            metric.endpoint_id == endpoint.id
        end
      end

      def create_metric(service, endpoint)
        Metrics::Endpoint.new(service, endpoint)
      end
    end
  end
end

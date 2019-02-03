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
  # :reek:TooManyInstanceVariables
  module Metrics
    #
    # Class EndpointStat provides metrics for stubbed endpoints
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    class EndpointStat
      # includes "Enumerable"
      # @!parse include Enumerable
      include Enumerable

      # @api private
      include Property

      #
      # @!attribute [r] service_id
      #   @return [Symbol] the id of a {Service}
      property :service_id, type: Symbol
      #
      # @!attribute [r] endpoint_id
      #   @return [Symbol] the id of an endpoint
      property :endpoint_id, type: Symbol
      #
      # @!attribute [r] verb
      #   @return [String] the HTTP verb/method for this endpoint
      property :verb, type: Symbol
      #
      # @!attribute [r] uri_template
      #   @return [String] the full URI template for the endpoint
      property :uri_template, type: Symbol
      #
      # @!attribute [r] stats
      #   @return [Array] an array with recorded request_stubs
      attr_reader :stats

      #
      # Initializes a new EndpointStat
      #
      # @param [Service] service a service
      # @param [Endpoint] endpoint an endpoint
      #
      def initialize(service, endpoint)
        @service_id   = service.id
        @endpoint_id  = endpoint.id
        @verb         = endpoint.verb
        @uri_template = [service.uri, endpoint.uri_template].join("/")
        @stats        = Concurrent::Array.new
      end

      def find_by(attribute:, value:)
        find { |stat| stat.send(attribute) == value }
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
        stats.each(&block)
      end

      #
      # Records a WebMock::RequestStub as stubbed
      #
      # @param [WebMock::RequestStub] request_stub <description>
      #
      # @return [Record]
      #
      def record(request_stub)
        stat = StubStat.new(self, request_stub)
        stats.push(stat)
        stat
      end
    end
  end
end

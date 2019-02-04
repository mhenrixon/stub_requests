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
  # :reek:TooManyInstanceVariables
  module Metrics
    #
    # Class Endpoint provides metrics for stubbed endpoints
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    class Endpoint
      # includes "Enumerable"
      # @!parse include Enumerable
      include Enumerable
      # @api private
      include Property
      # @api private

      #
      # @!attribute [r] service_id
      #   @return [Symbol] the id of a {StubRequests::Registration::Service}
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
      property :uri_template, type: String
      #
      # @!attribute [r] stubs
      #   @return [Array] an array with recorded requests
      attr_reader :requests

      #
      # Initializes a new Endpoint
      #
      # @param [Registration::Service] service a service
      # @param [Registration::Endpoint] endpoint an endpoint
      #
      def initialize(service, endpoint)
        self.service_id   = service.id
        self.endpoint_id  = endpoint.id
        self.verb         = endpoint.verb
        self.uri_template = [service.uri, endpoint.uri_template].join("/")

        @requests = Concurrent::Array.new
      end

      def find_by(attribute:, value:)
        find { |request| request.send(attribute) == value }
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
        requests.each(&block)
      end

      #
      # Records a WebMock::RequestStub as stubbed
      #
      # @param [WebMock::RequestStub] request_stub <description>
      #
      # @return [Record]
      #
      def record(request_stub)
        request = Request.new(self, request_stub)
        requests.push(request)
        request
      end
    end
  end
end

# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Endpoint provides metrics for stubbed endpoints
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  class EndpointStub
    # includes "Enumerable"
    # @!parse include Enumerable
    include Enumerable
    # @api private
    include Property
    # @api private

    #
    # @!attribute [r] service_id
    #   @return [Symbol] the id of a {StubRequests::Service}
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
    #   @return [Array] an array with recorded stubs
    attr_reader :stubs

    #
    # Initializes a new Endpoint
    #
    # @param [Service] service a service
    # @param [Endpoint] endpoint an endpoint
    #
    def initialize(service, endpoint)
      self.service_id   = service.id
      self.endpoint_id  = endpoint.id
      self.verb         = endpoint.verb
      self.uri_template = [service.uri, endpoint.uri_template].join("/")

      @stubs = Concurrent::Array.new
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
      stubs.each(&block)
    end

    #
    # Records a WebMock::RequestStub as stubbed
    #
    # @param [WebMock::RequestStub] webmock_stub <description>
    #
    # @return [RequestStub]
    #
    def record(webmock_stub)
      request_stub = RequestStub.new(self, webmock_stub)
      stubs.push(request_stub)
      request_stub
    end
  end
end

# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module API abstraction to reduce the amount of WebMock.stub_request
  #
  # @note This module can either be used by its class methods
  #   or included in say RSpec
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  # :reek:DataClump
  module API
    # extends "self"
    # @!parse extend self
    extend self

    # :reek:LongParameterList { max_params: 4 }
    # @api private
    def self._stub_endpoint(service_id, endpoint_id, uri_replacements = {}, options = {})
      _service, endpoint, uri = StubRequests::URI.for_service_endpoint(service_id, endpoint_id, uri_replacements)
      endpoint_stub           = WebMock::Builder.build(endpoint.verb, uri, options)

      ::WebMock::StubRegistry.instance.register_request_stub(endpoint_stub)
    end

    # :nodoc:
    def self.included(base)
      base.send(:extend, self)
    end

    # Register a service in the service registry
    #
    #
    # @param [Symbol] service_id a descriptive id for the service
    # @param [Symbol] service_uri the uri used to call the service
    #
    # @example Register a service with endpoints
    #   register_service(:documents, "https://company.com/api/v1") do
    #     register_endpoints do
    #       register(:show, :get, "documents/:id")
    #       register(:index, :get, "documents")
    #       register(:create, :post, "documents")
    #       register(:update, :patch, "documents/:id")
    #       register(:destroy, :delete, "documents/:id")
    #     end
    #   end
    #
    # @return [Service] a new service or a previously registered service
    #
    # :reek:UtilityFunction
    def register_service(service_id, service_uri, &block)
      service = ServiceRegistry.instance.register(service_id, service_uri)
      Docile.dsl_eval(service.endpoints, &block) if block.present?
      service
    end

    #
    # Stub a request to a registered service endpoint
    #
    #
    # @param [Symbol] service_id the id of a registered service
    # @param [Symbol] endpoint_id the id of a registered endpoint
    # @param [Hash<Symbol>] uri_replacements a list of URI replacements
    # @param [Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request webmock request options
    # @option options [optional, Hash<Symbol>] :response webmock response options
    # @option options [optional, Array, Exception, StandardError, String] :error webmock error to raise
    # @option options [optional, TrueClass] :timeout set to true to raise some kind of timeout error
    #
    # @note the kind of timeout error raised by webmock is depending on the HTTP client used
    #
    # @example Stub a request to a registered service endpoint
    #   register_stub(
    #     :google_api,
    #     :get_map_location,
    #     {}, # No URI replacements needed for this endpoint
    #     { request: { headers: { "Accept" => "application/json" }}},
    #     { response: { body: { id: "abyasdjasd", status: "successful" }}}
    #   )
    #
    # @example Stub a request to a registered service endpoint using block version
    #   register_stub(:documents, :index) do
    #     with(headers: { "Accept" => "application/json" }}})
    #     to_return(body: "No content", status: 204)
    #   end
    #
    # @see #stub_http_request
    # @return [WebMock::RequestStub] a mocked request
    #
    # :reek:UtilityFunction
    # :reek:LongParameterList { max_params: 5 }
    def stub_endpoint(service_id, endpoint_id, uri_replacements = {}, options = {}, &callback)
      service, endpoint, uri = StubRequests::URI.for_service_endpoint(service_id, endpoint_id, uri_replacements)
      endpoint_stub          = WebMock::Builder.build(endpoint.verb, uri, options, &callback)

      Metrics.record(service, endpoint, endpoint_stub)
      ::WebMock::StubRegistry.instance.register_request_stub(endpoint_stub)
    end
  end
end

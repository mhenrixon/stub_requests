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
  module API
    # extends "self"
    # @!parse extend self
    extend self

    # :nodoc:
    def self.included(base)
      base.send(:extend, self)
    end

    # Register a service in the service registry
    #
    # @param [Symbol] service_id a descriptive id for the service
    # @param [Symbol] service_uri the uri used to call the service
    #
    # @return [Service] a new service or a previously registered service
    #
    # :reek:UtilityFunction
    def register_service(service_id, service_uri, &block)
      service = ServiceRegistry.instance.register_service(service_id, service_uri)
      Docile.dsl_eval(service.endpoint_registry, &block) if block.present?
      service
    end

    #
    # Stub a request to a registered service endpoint
    #
    # @param [Symbol] service_id the id of a registered service
    # @param [Symbol] endpoint_id the id of a registered endpoint
    # @param [Hash<Symbol>] uri_replacements a list of uri replacements
    # @param [Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request webmock request options
    # @option options [optional, Hash<Symbol>] :response webmock response options
    # @option options [optional, Array, Exception, StandardError, String] :error webmock error to raise
    # @option options [optional, TrueClass] :timeout set to truthy to raise timeeout with webmock
    #
    # @example Stub a request to a registered service endpoint
    #   register_stub(
    #     :google_api,
    #     :get_map_location,
    #     { request: { headers: { "Accept" => "application/json" }}},
    #     { response: { body: { id: "abyasdjasd", status: "successful" }}}
    #   )
    #
    # @see #stub_http_request
    # @return [WebMock::RequestStub] a mocked request
    #
    # :reek:UtilityFunction
    # :reek:LongParameterList { max_params: 5 }
    def stub_endpoint(service_id, endpoint_id, uri_replacements = {}, options = {}, &callback)
      service  = ServiceRegistry.instance.get_service!(service_id)
      endpoint = service.get_endpoint!(endpoint_id)
      uri      = URI::Builder.build(service.uri, endpoint.uri_template, uri_replacements)

      request_stub = build_request_stub(endpoint.verb, uri, options, &callback)
      record_metrics(service, endpoint, request_stub)
      register_request_stub(request_stub)
    end

    private

    def build_request_stub(verb, uri, options, &callback)
      StubRequests::WebMockBuilder.build(verb, uri, options, &callback)
    end

    def record_metrics(service, endpoint, request_stub)
      StubRequests::Metrics::Registry.instance.record_metric(service, endpoint, request_stub)
    end

    def register_request_stub(request_stub)
      WebMock::StubRegistry.instance.register_request_stub(request_stub)
    end
  end
end

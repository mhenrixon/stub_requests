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
  module API
    # extends "self"
    # @!parse extend self
    extend self

    # includes "UriFor" and extends "UriFor"
    # using the UriFor.included callback
    # @!parse include UriFor
    # @!parse extend UriFor
    include UriFor

    # :nodoc:
    def self.included(base)
      base.send(:extend, self)
    end

    # Return the singleton instance of the ServiceRegistry
    # @return [ServiceRegistry] a mocked request
    def service_registry
      ServiceRegistry.instance
    end

    # Register a service in the service registry
    #
    # @param [Symbol] service_id a descriptive id for the service
    # @param [Symbol] service_uri the uri used to call the service
    #
    # @return [Service] a new service or a previously registered service
    #
    def register_service(service_id, service_uri, &block)
      service = service_registry.register_service(
        Service.new(service_id, service_uri),
      )

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
    # @option options [optional, Hash<Symbol>] :request see {#prepare_request}
    # @option options [optional, Hash<Symbol>] :response see {#prepare_response}
    # @option options [optional, Array, Exception, StandardError, String] :error see {#prepare_error}
    # @option options [optional, TrueClass] :timeout if the stubbed request should raise Timeout
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
    def stub_endpoint(service_id, endpoint_id, uri_replacements = {}, options = {}, &callback)
      service      = service_registry.get_service!(service_id)
      endpoint     = service.get_endpoint!(endpoint_id)
      uri          = uri_for(service.uri, endpoint.uri_template, uri_replacements)

      StubRequests::WebMockBuilder.build(endpoint.verb, uri, options, &callback)
    end
  end
end

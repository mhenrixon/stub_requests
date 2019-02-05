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
      StubRequests::ServiceRegistry.register_service(service_id, service_uri, &block)
    end

    #
    # Stub a request to a registered service endpoint
    #
    #
    # @param [Symbol] service_id the id of a registered service
    # @param [Symbol] endpoint_id the id of a registered endpoint
    # @param [Hash<Symbol>] route_params a map with route parameters
    #
    # @note the kind of timeout error raised by webmock is depending on the HTTP client used
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
    def stub_endpoint(service_id, endpoint_id, route_params = {}, &callback)
      StubRequests::ServiceRegistry.stub_endpoint(service_id, endpoint_id, route_params, &callback)
    end

    #
    # Subscribe to notifications for a service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Symbol] verb an HTTP verb/method
    # @param [Proc] callback a Proc to call when receiving response
    #
    # @return [void]
    #
    # :reek:UtilityFunction
    # :reek:LongParameterList
    def register_callback(service_id, endpoint_id, verb, callback)
      StubRequests::CallbackRegistry.register(service_id, endpoint_id, verb, callback)
    end

    #
    # Unsubscribe from notifications for a service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    #
    # @return [void]
    #
    # :reek:UtilityFunction
    def unregister_callback(service_id, endpoint_id, verb)
      StubRequests::CallbackRegistry.unregister(service_id, endpoint_id, verb)
    end
  end
end

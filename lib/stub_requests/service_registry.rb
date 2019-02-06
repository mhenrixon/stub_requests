# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Class Registry provides registration of services
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  class ServiceRegistry
    include Singleton
    include Enumerable

    # Register a service in the service registry
    #
    #
    # @param [Symbol] service_id a descriptive id for the service
    # @param [Symbol] service_uri the uri used to call the service
    #
    # @example Register a service with endpoints
    #   register_service(:documents, "https://company.com/api/v1") do
    #     register(:show, :get, "documents/:id")
    #     register(:index, :get, "documents")
    #     register(:create, :post, "documents")
    #     register(:update, :patch, "documents/:id")
    #     register(:destroy, :delete, "documents/:id")
    #   end
    #
    # @return [Service] a new service or a previously registered service
    #
    def self.register_service(service_id, service_uri, &block)
      service = instance.register(service_id, service_uri)
      Docile.dsl_eval(service.endpoints, &block) if block.present?
      service
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
    # @example Stub a request to a registered service endpoint
    #   register_stub(
    #     :google_api,
    #     :get_map_location,
    #     {}, # No URI replacements needed for this endpoint
    #   )
    #   .to_return(body: "No content", status: 204)
    #
    # @example Stub a request to a registered service endpoint using block
    #   register_stub(:documents, :index) do
    #     with(headers: { "Accept" => "application/json" }}})
    #     to_return(body: "No content", status: 204)
    #   end
    #
    # @see #stub_http_request
    # @return [WebMock::RequestStub] a mocked request
    #
    def self.stub_endpoint(service_id, endpoint_id, route_params = {}, &callback)
      service, endpoint, uri = StubRequests::URI.for_service_endpoint(service_id, endpoint_id, route_params)
      endpoint_stub          = WebMock::Builder.build(endpoint.verb, uri, {}, &callback)

      StubRegistry.record(service, endpoint, endpoint_stub)
      ::WebMock::StubRegistry.instance.register_request_stub(endpoint_stub)
    end

    # @api private
    # Used only for testing purposes
    def self.__stub_endpoint(service_id, endpoint_id, route_params = {})
      _service, endpoint, uri = StubRequests::URI.for_service_endpoint(service_id, endpoint_id, route_params)
      endpoint_stub           = WebMock::Builder.build(endpoint.verb, uri)

      ::WebMock::StubRegistry.instance.register_request_stub(endpoint_stub)
    end

    #
    # @!attribute [rw] services
    #   @return [Concurrent::Map<Symbol, Service>] a map with services
    attr_reader :services

    def initialize
      @services = Concurrent::Map.new
    end

    #
    # Resets the map with registered services
    #
    #
    # @api private
    def reset
      services.clear
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
      services.each(&block)
    end

    #
    # Registers a service in the registry
    #
    #
    # @param [Symbol] service_id a symbolic id of the service
    # @param [String] service_uri a string with a base_uri to the service
    #
    # @return [Service] the service that was just registered
    #
    def register(service_id, service_uri)
      if (service = find(service_id))
        StubRequests.logger.warn("Service already registered #{service}")
        raise ServiceHaveEndpoints, service if service.endpoints?
      end
      services[service_id] = Service.new(service_id, service_uri)
    end

    #
    # Removes a service from the registry
    #
    #
    # @param [Symbol] service_id the service_id to remove
    #
    # @raise [ServiceNotFound] when the service was not removed
    #
    def remove(service_id)
      services.delete(service_id) || raise(ServiceNotFound, service_id)
    end

    #
    # Fetches a service from the registry
    #
    #
    # @param [Symbol] service_id id of the service to remove
    #
    # @return [Service] the found service
    #
    def find(service_id)
      services[service_id]
    end

    #
    # Fetches a service from the registry or raises {ServiceNotFound}
    #
    #
    # @param [Symbol] service_id the id of a service
    #
    # @raise [ServiceNotFound] when an endpoint couldn't be found
    #
    # @return [Service]
    #
    def find!(service_id)
      find(service_id) || raise(ServiceNotFound, service_id)
    end
  end
end

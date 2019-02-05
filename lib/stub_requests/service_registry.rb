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
    # @return [Registration::Service] the service that was just registered
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
    # @return [Registration::Service] the found service
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
    # @return [Registration::Service]
    #
    def find!(service_id)
      find(service_id) || raise(ServiceNotFound, service_id)
    end
  end
end

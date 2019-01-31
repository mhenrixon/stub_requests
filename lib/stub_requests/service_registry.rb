# frozen_string_literal: true

require "singleton"
require "concurrent/map"

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
  class ServiceRegistry
    include Singleton

    # @return [Concurrent::Map] the map with registered services
    attr_accessor :services

    def initialize
      self.services = Concurrent::Map.new
    end

    #
    # Resets the map with registered services
    # @api private
    def reset!
      services.clear
    end

    #
    # Registers a service in the registry
    #
    # @param [Service] service the service to add to the registry
    #
    # @return [Service] the service that was just registered
    #
    def register_service(service)
      if (old_service = get_service(service.id))
        StubRequests.logger.warn("Service already registered #{service}")
        raise ServiceHaveEndpoints, old_service if old_service.endpoints?
      end
      services[service.id] = service
    end

    #
    # Removes a service from the registry
    #
    # @param [Symbol] service_id the service_id to remove
    #
    # @raise [ServiceNotFound] when the service was not removed
    #
    def remove_service(service_id)
      services.delete(service_id) || raise(ServiceNotFound, service_id)
    end

    #
    # Fetches a service from the registry
    #
    # @param [Symbol] service_id id of the service to remove
    #
    # @return [Service] the found service
    #
    def get_service(service_id)
      services[service_id]
    end

    #
    # Fetches a service from the registry
    #
    # @param [Symbol] service_id the id of a service
    #
    # @raise [ServiceNotFound] when an endpoint couldn't be found
    #
    # @return [Endpoint, nil]
    #
    def get_service!(service_id)
      get_service(service_id) || raise(ServiceNotFound, service_id)
    end
  end
end

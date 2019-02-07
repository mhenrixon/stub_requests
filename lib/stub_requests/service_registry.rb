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
    # extend "Forwardable"
    # @!parse extend Forwardable
    extend Forwardable

    # includes "Singleton"
    # @!parse include Singleton
    include Singleton
    # includes "Enumerable"
    # @!parse include Enumerable
    include Enumerable

    delegate [:each, :[], :[]=, :keys, :delete] => :services

    #
    # @!attribute [rw] services
    #   @return [Concurrent::Map<Symbol, Service>] a map with services
    attr_reader :services

    #
    # Initialize a new instance (used by Singleton)
    #
    #
    def initialize
      @services = Concurrent::Map.new
    end

    #
    # Returns the size of the registry
    #
    #
    # @return [Integer]
    #
    def size
      keys.size
    end
    alias count size

    #
    # Resets the map with registered services
    #
    #
    # @api private
    def reset
      services.clear
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
      service = Service.new(service_id, service_uri)
      StubRequests.logger.warn("Service already registered #{service}") if self[service_id]

      self[service_id] = service
      service
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
      delete(service_id) || raise(ServiceNotFound, service_id)
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
      self[service_id]
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
      self[service_id] || raise(ServiceNotFound, service_id)
    end
  end
end

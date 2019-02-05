# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module URI organizes all gem logic regarding URI
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module URI
    #
    # @return [Regexp] A pattern for matching route parameters
    ROUTE_PARAM = %r{/:(\w+)/?}.freeze

    #
    # Extracts route parameters from a string
    #
    # @param [String] string a regular string to scan for route parameters
    #
    # @return [Array<Symbol>] an array with all route parameter keys
    #
    def self.route_params(string)
      string.scan(ROUTE_PARAM).flatten.map(&:to_sym)
    end

    #
    # Safely joins two string without any extra ///
    #
    # @param [String] host the host of the URI
    # @param [String] path the path of the URI
    #
    # @return [String] the full URI
    #
    def self.safe_join(host, path)
      [host.chomp("/"), path.sub(%r{\A/}, "")].join("/")
    end

    #
    # UtilityFunction to construct the full URI for a service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Hash<Symbol>] replacements hash with replacements
    #
    # @return [Array<Service, Endpoint, String] the service, endpoint and full URI
    #
    def self.for_service_endpoint(service_id, endpoint_id, replacements)
      service  = ServiceRegistry.instance.find!(service_id)
      endpoint = service.endpoints.find!(endpoint_id)
      uri      = URI::Builder.build(service.uri, endpoint.path, replacements)

      [service, endpoint, uri]
    end
  end
end

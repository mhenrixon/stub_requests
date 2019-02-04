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
    # UtilityFunction to construct the full URI for a service endpoint
    #
    # @param [Symbol] service_id the id of a service
    # @param [Symbol] endpoint_id the id of an endpoint
    # @param [Hash<Symbol>] replacements hash with replacements
    #
    # @return [Array<Service, Endpoint, String] the service, endpoint and full URI
    #
    def self.for_service_endpoint(service_id, endpoint_id, replacements)
      service  = Registration::Registry.instance.find!(service_id)
      endpoint = service.endpoints.find!(endpoint_id)
      uri      = URI::Builder.build(service.uri, endpoint.uri_template, replacements)

      [service, endpoint, uri]
    end
  end
end

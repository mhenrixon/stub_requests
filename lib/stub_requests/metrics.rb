# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Metrics contains logic for collecting metrics about {EndpointStat} and {StubStat}
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module Metrics
    #
    # Records metrics about stubbed endpoints
    #
    # @param [Service] service a Service
    # @param [Endpoint] endpoint an Endpoint
    # @param [WebMock::RequestStub] endpoint_stub the stubbed webmock request
    #
    # @return [EndpointStat] the stat that was recorded
    #
    def self.record(service, endpoint, endpoint_stub)
      return unless StubRequests.config.record_metrics?

      Registry.instance.record(service, endpoint, endpoint_stub)
    end
  end
end

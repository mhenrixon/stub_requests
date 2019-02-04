# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Registration provides registration of stubbed endpoints and services
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.3
  #
  module Registration
    #
    # Class Service provides details for a registered service
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    class Service
      include Comparable
      include Property

      # @!attribute [rw] id
      #   @return [Symbol] the id of the service
      property :id, type: Symbol

      # @!attribute [rw] uri
      #   @return [String] the base uri to the service
      property :uri, type: String

      # @!attribute [rw] endpoints
      #   @return [Endpoints] a list with defined endpoints
      attr_reader :endpoints

      #
      # Initializes a new instance of a Service
      #
      # @param [Symbol] service_id the id of this service
      # @param [String] service_uri the base uri to reach the service
      #
      def initialize(service_id, service_uri)
        self.id    = service_id
        self.uri   = service_uri
        @endpoints = Endpoints.new
      end

      #
      # Check if the endpoint registry has endpoints
      #
      # @return [true,false]
      #
      def endpoints?
        endpoints.any?
      end

      #
      # Returns a nicely formatted string with this service
      #
      # @return [String]
      #
      def to_s
        [
          +"#<#{self.class}",
          +" id=#{id}",
          +" uri=#{uri}",
          +" endpoints=#{endpoints.endpoints_string}",
          +">",
        ].join("")
      end

      def <=>(other)
        id <=> other.id
      end

      def hash
        [id, self.class].hash
      end

      alias eql? ==
    end
  end
end

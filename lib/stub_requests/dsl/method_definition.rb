# frozen_string_literal: true

module StubRequests
  class DSL
    #
    # Class DefineMethod generates method definition for a stubbed endpoint
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.4
    #
    class MethodDefinition
      #
      # @return [String]
      BLOCK_ARG = "&block"

      #
      # @!attribute [r] service_id
      #   @return [Symbol] the id of a registered service
      attr_reader :service_id
      #
      # @!attribute [r] endpoint_id
      #   @return [Symbol] the id of a registered endpoint
      attr_reader :endpoint_id
      #
      # @!attribute [r] route_params
      #   @return [Array<Symbol>] the URI parameters for the endpoint
      attr_reader :route_params

      #
      # Initialize a new endpoint of {MethodDefinition}
      #
      # @param [Symbol] service_id the id of a registered service
      # @param [Symbol] endpoint_id the id of a registered endpoint
      # @param [Array<Symbol>] route_params the route parameter keys
      #
      def initialize(service_id, endpoint_id, route_params)
        @service_id   = service_id
        @endpoint_id  = endpoint_id
        @route_params = route_params
      end

      #
      # The name of this method
      #
      #
      # @return [String] a string prefixed with stub_, `"stub_documents_show"`
      #
      def name
        @name ||= "stub_#{endpoint_id}"
      end

      def to_s
        <<~METHOD
          def #{name}(#{keywords})
            stub_endpoint(:#{service_id}, :#{endpoint_id}, #{arguments})
          end
        METHOD
      end
      alias to_str to_s

      private

      def keywords
        @keywords ||= route_params.map { |param| "#{param}:" }.concat([+BLOCK_ARG]).join(", ")
      end

      def arguments
        @arguments ||= route_params.map { |param| "#{param}: #{param}" }.concat([+BLOCK_ARG]).join(", ")
      end
    end
  end
end

# frozen_string_literal: true

module StubRequests
  class DSL
    #
    # Class DefineMethod defines helper methods for stubbed endpoints
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.4
    #
    class DefineMethod
      #
      # @!attribute [r] definition
      #   @return [MethodDefinition] the method definition
      attr_reader :definition
      #
      # @!attribute [r] receiver
      #   @return [Module] the receiver of the method definition
      attr_reader :receiver

      #
      # Initialize a new instance of DefineMethod
      #
      #
      # @param [MethodDefinition] definition the method definition
      # @param [Module] receiver the receiver of the method definition
      #
      def initialize(definition, receiver)
        @receiver   = receiver
        @definition = definition
      end

      #
      # Define the {MethodDefinition#to_s} on the receiver
      #
      #
      # @return [void]
      #
      def define
        Docile.dsl_eval(receiver) do
          silence_redefinition_of_method(definition.name)
          module_eval <<~METHOD, __FILE__, __LINE__ + 1
            #{definition}
          METHOD
        end
      end
    end
  end
end

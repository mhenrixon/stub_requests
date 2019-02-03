# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Property provides type checked attribute definition with default value
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module Property
    #
    # Class Validator provides validation for adding properties
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    class Validator
      include ArgumentValidation

      #
      # Validates that the property can be added to the class
      #
      #
      # @param [Symbol] name the name of the property
      # @param [Class, Module] type the type of the property
      # @param [Object] default the default value of the property
      # @param [Hash] properties the list of currently defined properties
      #
      # @raise [InvalidArgumentType] when name is not a {Symbol}
      # @raise [InvalidArgumentType] when default does not match {#type}
      # @raise [PropertyDefined] when property has already been defined
      #
      # @return [void]
      #
      # :reek:LongParameterList
      def self.call(name, type, default, properties)
        new(name, type, default, properties).run_validations
      end

      #
      # @!attribute [r] name
      #   @return [Symbol] the name of the property
      attr_reader :name
      #
      # @!attribute [r] type
      #   @return [Class, Module] the type of the property
      attr_reader :type
      #
      # @!attribute [r] default
      #   @return [Object] the default value of the property
      attr_reader :default
      #
      # @!attribute [r] properties
      #   @return [Hash] the list of currently defined properties
      attr_reader :properties

      # Initializes a new {Validator}
      #
      # @param [Symbol] name the name of the property
      # @param [Class, Module] type the type of the property
      # @param [Object] default the default value of the property
      # @param [Hash] properties the list of currently defined properties
      #
      # :reek:LongParameterList
      def initialize(name, type, default, properties)
        @name       = name
        @type       = Array(type).flatten
        @default    = default
        @properties = properties
      end

      #
      # Performs all validations
      #
      #
      # @raise [InvalidArgumentType] when name is not a {Symbol}
      # @raise [InvalidArgumentType] when default does not match {#type}
      # @raise [PropertyDefined] when property has already been defined
      #
      # @return [void]
      #
      def run_validations
        validate_undefined
        validate_name
        validate_default
      end

      private

      #
      # Validates that the name is of type Symbol
      #
      # @raise [InvalidArgumentType] when name is not a {Symbol}
      #
      # @return [void]
      #
      def validate_name
        validate! :name, name, is_a: Symbol
      end

      #
      # Validate that the default value matches the {#type}
      #
      #
      # @raise [InvalidArgumentType] when default does not match {#type}
      #
      # @return [void]
      #
      def validate_default
        return unless default || default.is_a?(FalseClass)
        validate! :default, default, is_a: type
      end

      #
      # Validate that the property has not been defined
      #
      #
      # @raise [PropertyDefined] when property has already been defined
      #
      # @return [void]
      #
      def validate_undefined
        return unless (prop = properties[name])

        raise PropertyDefined, name: name, type: prop[:type], default: prop[:default]
      end
    end
  end
end

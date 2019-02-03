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
      # @param [Hash] defined_properties the list of currently defined properties
      #
      # @raise [InvalidType] when name is not a {Symbol}
      # @raise [InvalidType] when default does not match {#type}
      # @raise [PropertyDefined] when property has already been defined
      #
      # @return [void]
      #
      def self.validate!(name, type, default, defined_properties)
        new(name, type, default, defined_properties).run_validations!
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
      # @!attribute [r] defined_properties
      #   @return [Hash] the list of currently defined properties
      attr_reader :defined_properties

      # Initializes a new {Validator}
      #
      # @param [Symbol] name the name of the property
      # @param [Class, Module] type the type of the property
      # @param [Object] default the default value of the property
      # @param [Hash] defined_properties the list of currently defined properties
      #
      def initialize(name, type, default, defined_properties)
        @name               = name
        @type               = type
        @default            = default
        @defined_properties = defined_properties
      end

      #
      # Performs all validations
      #
      #
      # @raise [InvalidType] when name is not a {Symbol}
      # @raise [InvalidType] when default does not match {#type}
      # @raise [PropertyDefined] when property has already been defined
      #
      # @return [void]
      #
      def run_validations!
        validate_undefined!
        validate_type_of_name!
        validate_type_of_default!
      end

      #
      # Validates that the name is of type Symbol
      #
      # @raise [InvalidType] when name is not a {Symbol}
      #
      # @return [void]
      #
      def validate_type_of_name!
        validate! name, is_a: Symbol
      end

      #
      # Validate that the default value matches the {#type}
      #
      #
      # @raise [InvalidType] when default does not match {#type}
      #
      # @return [void]
      #
      def validate_type_of_default!
        validate! default, is_a: type if default || default == false
      end

      #
      # Validate that the property has not been defined
      #
      #
      # @raise [PropertyDefined] when property has already been defined
      #
      # @return [void]
      #
      def validate_undefined!
        old_definition = defined_properties[name]
        raise PropertyDefined, name, old_definition if old_definition.present?
      end
    end
  end
end

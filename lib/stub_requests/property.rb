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
    include ArgumentValidation

    #
    # Extends the base class with the ClassMethods module
    #
    # @param [Class,Module] base the class where this module is included
    #
    # @return [void]
    #
    def self.included(base)
      base.instance_exec do
        @properties = {}
      end

      base.send(:extend, ClassMethods)
    end

    def properties
      self.class.properties
    end

    #
    # Module ClassMethods provides class methods for {Properties}
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    module ClassMethods
      #
      # Define property methods for the name
      #
      # @param [Symbol, String] name the name of the attribute
      # @param [Array<Class>, Class] type: the expected type on the attribute
      # @param [Object] default: nil the default value for the attribute
      #
      # @return [void]
      #
      def property(name, type:, default: nil)
        Property::Validator.validate!(name, type, default, properties)

        instance_exec do
          define_attribute_methods(name, type, default)
        end
      end

      def properties
        @properties
      end

      def define_attribute_methods(name, type, default)
        define_attr_reader(name)
        define_attr_writer(name, type)
        define_query_reader(name)
      end

      def define_attr_reader(name)
        define_method(name) do
          instance_variable_get(:"@#{name}")
        end

        define_method("default_value_for_#{name}") do
          return nil unless (definition = properties[name])
          definition[:default]
        end
      end

      def define_attr_writer(name, type)
        define_method("#{name}=") do |value|
          validate! value, is_a: type
          instance_variable_set(:"@#{name}", value)
        end
      end

      def define_query_reader(name)
        define_method("#{name}?") do
          !!send(name) # rubocop:disable Style/DoubleNegation
        end
      end
    end
  end
end

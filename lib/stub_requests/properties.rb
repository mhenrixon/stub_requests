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
  module Properties
    include ArgumentValidation

    #
    # Extends the base class with the ClassMethods module
    #
    # @param [Class,Module] base the class where this module is included
    #
    # @return [void]
    #
    def self.included(base)
      base.send(:extend, ClassMethods)
    end

    #
    # Module ClassMethods provides class methods for {Properties}
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    module ClassMethods
      #
      # Generates attr_accessor for the name
      #
      # @param [Symbol, String] name the name of the attribute
      # @param [Array<Class>, Class] type: the expected type on the attribute
      # @param [Object] default: nil the default value for the attribute
      #
      # @return [<type>] <description>
      #
      def property(name, type:, default: nil)
        ArgumentValidation.validate! default, is_a: type if default || default != false
        defined_properties[name] = { type: type, default: default }

        instance_exec do
          define_attribute_methods(name, type, default)
        end
      end

      def defined_properties
        @defined_properties ||= Concurrent::Map.new
      end

      def define_attribute_methods(name, type, default)
        define_attr_reader(name)
        define_attr_writer(name, type)
        define_query_reader(name)
      end

      def define_attr_reader(name)
        define_method(name) do
          instance_variable_get(:"@#{name}") || defined_properties[name][:default]
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

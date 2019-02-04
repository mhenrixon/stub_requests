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
      base.class_attribute :properties, default: {}
      base.send(:extend, ClassMethods)
    end

    #
    # Module ClassMethods provides class methods for {Property}
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    # :reek:DataClump
    module ClassMethods
      #
      # Define property methods for the name
      #
      # @param [Symbol] name the name of the property
      # @param [Object] type the expected type of the property
      # @param [Hash<Symbol>] options a hash with options
      # @option options [Object] :default a default value for the property
      #
      # @return [Object] the whatever
      #
      def property(name, type:, **options)
        type = normalize_type(type, options)
        default = options[:default]
        Property::Validator.call(name, type, default, properties)

        Docile.dsl_eval(self) do
          define_property(name, type, default)
        end
      end

      # @api private
      def normalize_type(type, **options)
        type_array = Array(type)
        return type_array unless (default = options[:default])

        type_array.concat([default.class]).flatten.uniq
      end

      # @api private
      def define_property(name, type, default)
        property_reader(name)
        property_predicate(name)
        property_writer(name, type)

        set_property_defined(name, type, default)
      end

      # @api private
      def property_reader(name)
        silence_redefinition_of_method(name.to_s)
        redefine_method(name) do
          instance_variable_get("@#{name}") || properties.dig(name, :default)
        end
      end

      # @api private
      def property_predicate(name)
        silence_redefinition_of_method("#{name}?")
        redefine_method("#{name}?") do
          !!public_send(name) # rubocop:disable Style/DoubleNegation
        end
      end

      # @api private
      def property_writer(name, type)
        redefine_method("#{name}=") do |obj|
          validate! name: name, value: obj, type: type
          instance_variable_set("@#{name}", obj)
        end
      end

      # @api private
      def set_property_defined(name, type, default)
        properties[name] = { type: type, default: default }
      end
    end
  end
end

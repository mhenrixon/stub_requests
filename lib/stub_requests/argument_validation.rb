# frozen_string_literal: true

require "addressable/uri"
require "public_suffix"

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module ArgumentValidation provides validation of method arguments
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module ArgumentValidation
    extend self

    #
    # Require the value to be any of the types past in
    #
    #
    # @param [Object] value the value to validate
    # @param [Array<Class>, Array<Module>, Class, Module] is_a
    #
    # @raise [InvalidArgumentType] when the value is disallowed
    #
    # @return [true] when the value is allowed
    #
    # :reek:UtilityFunction
    def validate!(name, value, is_a:)
      validate! :name, name, is_a: [Symbol, String] unless name

      expected_types = Array(is_a).flatten
      return true if validate(value, expected_types)

      raise StubRequests::InvalidArgumentType,
            name: name,
            actual: value.class,
            expected: expected_types
    end

    # :reek:UtilityFunction
    def validate(value, expected_types)
      expected_types.any? { |type| value.is_a?(type) }
    end
  end
end

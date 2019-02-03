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
    # @raise [InvalidType] when the value is disallowed
    #
    # @return [true] when the value is allowed
    #
    def validate!(value, is_a:)
      expected_types = Array(is_a)
      return true if validate(value, expected_types)

      raise StubRequests::InvalidType,
            actual: value.class,
            expected: expected_types.join(", ")
    end

    def validate(value, expected_types)
      expected_types.any? { |type| value.is_a?(type) }
    end
  end
end

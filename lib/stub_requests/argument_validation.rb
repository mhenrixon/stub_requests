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
    # @param [Symbol] name: the name of the argument
    # @param [Object] value: the actual value of the argument
    # @param [Array, Class, Module] type: nil the expected argument value class
    # @param [Integer] arity: nil the number of expected arguments the argument should have
    #
    # @raise [InvalidArgumentType] when the value is disallowed
    #
    # @return [void]
    #
    # :reek:UtilityFunction
    def validate!(name:, value:, type: nil, arity: nil)
      validate_type!(name, value, type)   if type
      validate_arity!(name, value, arity) if arity
    end

    #
    # Validate that the argument arity is of the same size
    #
    #
    # @raise [InvalidCallback] when arity does not match
    #
    # @return [void]
    #
    def validate_arity!(name, value, arity)
      return validate_proc!(name, value, arity) if value.is_a?(Proc)
    end

    def validate_proc!(name, value, arity)
      return if arity == value.arity

      raise InvalidCallback,
            name: name,
            expected: arity,
            actual: value.arity
    end


    # :reek:UtilityFunction
    def validate_type!(name, value, type)
      expected_types = Array(type).flatten
      return if expected_types.any? { |is_a| value.is_a?(is_a) }

      raise StubRequests::InvalidArgumentType,
            name: name,
            actual: value.class,
            expected: expected_types
    end
  end
end

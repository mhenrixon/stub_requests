# frozen_string_literal: true

# :nodoc:
# @api private
class String
  # :nodoc:
  # @api private
  def to_route_param
    return self if start_with?(":")

    ":#{+self}"
  end unless method_defined?(:to_route_param)
end

# :nodoc:
# @api private
class Symbol
  # :nodoc:
  # @api private
  def to_route_param
    to_s.to_route_param
  end unless method_defined?(:to_route_param)
end

# :nodoc:key => "value",
# @api private
class Hash
  # :nodoc:
  # @api private
  def to_route_param
    each_with_object({}) do |(key, value), memo|
      memo[key.to_route_param] = value
    end
  end unless method_defined?(:to_route_param)
end

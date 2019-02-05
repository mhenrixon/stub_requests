# frozen_string_literal: true

# Copied from https://raw.githubusercontent.com/rails/rails/d66e7835bea9505f7003e5038aa19b6ea95ceea1/activesupport/lib/active_support/core_ext/object/blank.rb

class String
  def to_route_param
    return self if start_with?(":")

    ":#{+self}"
  end unless method_defined?(:to_route_param)
end

class Symbol
  def to_route_param
    to_s.to_route_param
  end unless method_defined?(:to_route_param)
end

class Hash
  def to_route_param
    each_with_object({}) do |(key, value), memo|
      memo[key.to_route_param] = value
    end
  end unless method_defined?(:to_route_param)
end

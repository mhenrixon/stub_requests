# frozen_string_literal: true

# :nodoc:

# See {Module}
# @api private
class Module
  # @api private
  # :nodoc:
  def silence_redefinition_of_method(method)
    if method_defined?(method) || private_method_defined?(method)
      alias_method :__stub_requests_redefine, method
      remove_method :__stub_requests_redefine
    end
  end unless method_defined?(:silence_redefinition_of_method)

  # Replaces the existing method definition, if there is one, with the passed
  # block as its body.
  # @api private
  # :nodoc:
  def redefine_method(method, &block)
    visibility = method_visibility(method)
    silence_redefinition_of_method(method)
    define_method(method, &block)
    send(visibility, method)
  end unless method_defined?(:redefine_method)

  # Replaces the existing singleton method definition, if there is one, with
  # the passed block as its body.
  # @api private
  # :nodoc:
  def redefine_singleton_method(method, &block)
    singleton_class.redefine_method(method, &block)
  end unless method_defined?(:redefine_singleton_method)

  # @api private
  # :nodoc:
  def method_visibility(method) # :nodoc:
    case
    when private_method_defined?(method)
      :private
    when protected_method_defined?(method)
      :protected
    else
      :public
    end
  end unless method_defined?(:method_visibility)
end

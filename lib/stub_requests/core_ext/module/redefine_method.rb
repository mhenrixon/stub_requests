# frozen_string_literal: true

unless defined?(Rails) || defined?(ActiveSupport)
  # See {Module}
  # @api private
  class Module
    # @api private
    def silence_redefinition_of_method(method)
      if method_defined?(method) || private_method_defined?(method)
        alias_method :__rails_redefine, method
        remove_method :__rails_redefine
      end
    end

    # Replaces the existing method definition, if there is one, with the passed
    # block as its body.
    # @api private
    def redefine_method(method, &block)
      visibility = method_visibility(method)
      silence_redefinition_of_method(method)
      define_method(method, &block)
      send(visibility, method)
    end

    # Replaces the existing singleton method definition, if there is one, with
    # the passed block as its body.
    # @api private
    def redefine_singleton_method(method, &block)
      singleton_class.redefine_method(method, &block)
    end

    # @api private
    def method_visibility(method) # :nodoc:
      case
      when private_method_defined?(method)
        :private
      when protected_method_defined?(method)
        :protected
      else
        :public
      end
    end
  end
end

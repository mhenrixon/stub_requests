# frozen_string_literal: true

unless defined?(Rails) || defined?(ActiveSupport)
  # See {Class}
  # @api private
  module Kernel
    # @api private
    def class_eval(*args, &block)
      singleton_class.class_eval(*args, &block)
    end
  end
end

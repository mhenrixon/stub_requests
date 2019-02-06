# frozen_string_literal: true

# :nodoc:
module Kernel
  # :nodoc:
  def class_eval(*args, &block)
    singleton_class.class_eval(*args, &block)
  end
end

# frozen_string_literal: true

# :nodoc:
class Hash
  # @api private
  def extractable_options?
    instance_of?(Hash)
  end
end

# :nodoc:
class Array
  # :nodoc:
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end

  # :nodoc:
  def extract_options
    if last.is_a?(Hash) && last.extractable_options?
      last
    else
      {}
    end
  end
end

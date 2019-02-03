# frozen_string_literal: true

# @see {Hash}
# @api private
class Hash
  # @api private
  def extractable_options?
    instance_of?(Hash)
  end
end

# @see {Array}
# @api private
class Array
  # @api private
  def extract_options!
    if last.is_a?(Hash) && last.extractable_options?
      pop
    else
      {}
    end
  end
end

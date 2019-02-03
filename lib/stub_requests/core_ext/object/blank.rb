# frozen_string_literal: true

# Copied from https://raw.githubusercontent.com/rails/rails/d66e7835bea9505f7003e5038aa19b6ea95ceea1/activesupport/lib/active_support/core_ext/object/blank.rb

unless defined?(Rails) || defined?(ActiveSupport)

  # @see Object
  # @api private
  class Object
    # @api private
    def blank?
      respond_to?(:empty?) ? !!empty? : !self # rubocop:disable Style/DoubleNegation
    end
    # @api private
    def present?
      !blank?
    end
    # @api private
    def presence
      self if present?
    end
  end

  # @see NilClass
  # @api private
  class NilClass
    # @api private
    def blank?
      true
    end
  end

  # @see FalseClass
  # @api private
  class FalseClass
    # @api private
    def blank?
      true
    end
  end

  # @see TrueClass
  # @api private
  class TrueClass
    # @api private
    def blank?
      false
    end
  end

  # @see Array
  # @api private
  class Array
    # @api private
    alias blank? empty?
  end

  # @see Hash
  # @api private
  class Hash
    # @api private
    alias blank? empty?
  end

  # @see String
  class String
    # :nodoc:
    # @api private
    BLANK_RE = /\A[[:space:]]*\z/.freeze
    # :nodoc:
    # @api private
    ENCODED_BLANKS = Concurrent::Map.new do |map, enc|
      map[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
    end

    # @api private
    def blank?
      # The regexp that matches blank strings is expensive. For the case of empty
      # strings we can speed up this method (~3.5x) with an empty? call. The
      # penalty for the rest of strings is marginal.
      empty? ||
        begin
          if  RUBY_VERSION >= "2.4"
            BLANK_RE.match?(self)
          else
            !!BLANK_RE.match(self)
          end
        rescue Encoding::CompatibilityError
          if  RUBY_VERSION >= "2.4"
            ENCODED_BLANKS[encoding].match?(self)
          else
            !!ENCODED_BLANKS[encoding].match(self)
          end
        end
    end
  end

  # @see Numeric
  # @api private
  class Numeric
    # @api private
    def blank?
      false
    end
  end

  # @see Time
  # @api private
  class Time
    # @api private
    def blank?
      false
    end
  end
end

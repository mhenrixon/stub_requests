# frozen_string_literal: true

# Copied from https://raw.githubusercontent.com/rails/rails/d66e7835bea9505f7003e5038aa19b6ea95ceea1/activesupport/lib/active_support/core_ext/object/blank.rb

# :nodoc:
class Object
  # :nodoc:
  def blank?
    respond_to?(:empty?) ? !!empty? : !self # rubocop:disable Style/DoubleNegation
  end unless method_defined?(:blank?)

  # :nodoc:
  def present?
    !blank?
  end unless method_defined?(:present?)

  # :nodoc:
  def presence
    self if present?
  end unless method_defined?(:presence)
end

# @see NilClass
# :nodoc:
class NilClass
  # :nodoc:
  def blank?
    true
  end unless method_defined?(:blank?)
end

# @see FalseClass
# :nodoc:
class FalseClass
  # :nodoc:
  def blank?
    true
  end unless method_defined?(:blank?)
end

# @see TrueClass
# :nodoc:
class TrueClass
  # :nodoc:
  def blank?
    false
  end unless method_defined?(:blank?)
end

# @see Array
# :nodoc:
class Array
  # :nodoc:
  alias blank? empty? unless method_defined?(:blank?)
end

# @see Hash
# :nodoc:
class Hash
  # :nodoc:
  alias blank? empty? unless method_defined?(:blank?)
end

# @see String
class String
  # :nodoc:
  # :nodoc:
  BLANK_RE ||= /\A[[:space:]]*\z/.freeze
  # :nodoc:
  # :nodoc:
  ENCODED_BLANKS ||= Concurrent::Map.new do |map, enc|
    map[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
  end

  # :nodoc:
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
  end unless method_defined?(:blank?)
end

# @see Numeric
# :nodoc:
class Numeric
  # :nodoc:
  def blank?
    false
  end unless method_defined?(:blank?)
end

# @see Time
# :nodoc:
class Time
  # :nodoc:
  def blank?
    false
  end unless method_defined?(:blank?)
end

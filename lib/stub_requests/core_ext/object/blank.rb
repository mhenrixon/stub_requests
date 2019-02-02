# frozen_string_literal: true

# Copied from https://raw.githubusercontent.com/rails/rails/d66e7835bea9505f7003e5038aa19b6ea95ceea1/activesupport/lib/active_support/core_ext/object/blank.rb

# :nodoc:

# @see Object
class Object
  # An object is blank if it's false, empty, or a whitespace string.
  # For example, +nil+, '', '   ', [], {}, and +false+ are all blank.
  #
  # This simplifies
  #
  #   !address || address.empty?
  #
  # to
  #
  #   address.blank?
  #
  # @return [true, false]
  def blank?
    respond_to?(:empty?) ? !!empty? : !self # rubocop:disable Style/DoubleNegation
  end unless respond_to?(:blank?)

  # An object is present if it's not blank.
  #
  # @return [true, false]
  def present?
    !blank?
  end unless respond_to?(:present?)

  # Returns the receiver if it's present otherwise returns +nil+.
  # <tt>object.presence</tt> is equivalent to
  #
  #    object.present? ? object : nil
  #
  # For example, something like
  #
  #   state   = params[:state]   if params[:state].present?
  #   country = params[:country] if params[:country].present?
  #   region  = state || country || 'US'
  #
  # becomes
  #
  #   region = params[:state].presence || params[:country].presence || 'US'
  #
  # @return [Object]
  def presence
    self if present?
  end unless respond_to?(:presence)
end

# @see NilClass
class NilClass
  # +nil+ is blank:
  #
  #   nil.blank? # => true
  #
  # @return [true]
  def blank?
    true
  end unless respond_to?(:blank?)
end

# @see FalseClass
class FalseClass
  # +false+ is blank:
  #
  #   false.blank? # => true
  #
  # @return [true]
  def blank?
    true
  end unless respond_to?(:blank?)
end

# @see TrueClass
class TrueClass
  # +true+ is not blank:
  #
  #   true.blank? # => false
  #
  # @return [false]
  def blank?
    false
  end unless respond_to?(:blank?)
end

# @see Array
class Array
  # An array is blank if it's empty:
  #
  #   [].blank?      # => true
  #   [1,2,3].blank? # => false
  #
  # @return [true, false]
  alias blank? empty?
end

# @see Hash
class Hash
  # A hash is blank if it's empty:
  #
  #   {}.blank?                # => true
  #   { key: 'value' }.blank?  # => false
  #
  # @return [true, false]
  alias blank? empty?
end

# @see String
class String
  BLANK_RE = /\A[[:space:]]*\z/.freeze
  ENCODED_BLANKS = Concurrent::Map.new do |map, enc|
    map[enc] = Regexp.new(BLANK_RE.source.encode(enc), BLANK_RE.options | Regexp::FIXEDENCODING)
  end

  # A string is blank if it's empty or contains whitespaces only:
  #
  #   ''.blank?       # => true
  #   '   '.blank?    # => true
  #   "\t\n\r".blank? # => true
  #   ' blah '.blank? # => false
  #
  # Unicode whitespace is supported:
  #
  #   "\u00a0".blank? # => true
  #
  # @return [true, false]
  def blank?
    # The regexp that matches blank strings is expensive. For the case of empty
    # strings we can speed up this method (~3.5x) with an empty? call. The
    # penalty for the rest of strings is marginal.
    empty? ||
      begin
        BLANK_RE.match?(self)
      rescue Encoding::CompatibilityError
        ENCODED_BLANKS[encoding].match?(self)
      end
  end unless respond_to?(:blank?)
end

# @see Numeric
class Numeric
  # No number is blank:
  #
  #   1.blank? # => false
  #   0.blank? # => false
  #
  # @return [false]
  def blank?
    false
  end unless respond_to?(:blank?)
end

# @see Time
class Time
  # No Time is blank:
  #
  #   Time.now.blank? # => false
  #
  # @return [false]
  def blank?
    false
  end unless respond_to?(:blank?)
end

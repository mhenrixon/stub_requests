# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module Utils provides a namespace for utility module
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module Utils
    #
    # Provides convenience methods for hashes
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    module Fuzzy
      #
      # @return [Regexp] a pattern excluding all except alphanumeric
      FILTER_REGEX = /(^\w\d)/.freeze
      #
      # Find strings that are similar
      #
      #
      # @param [String] original a string to match
      # @param [Array<String>] others an array of string to search
      #
      # @return [Array] Returns
      #
      def self.match(original, others)
        matches = compute_distances(original, others).sort.reverse
        filter_matches(matches.to_h)
      end

      # :nodoc:
      def self.filter_matches(matches)
        suggestions = matches.values
        return suggestions if suggestions.size <= 3

        matches.select { |distance, _| distance >= 0.7 }
               .values
      end

      # :nodoc:
      def self.compute_distances(original, others)
        others.each_with_object([]) do |other, memo|
          memo << [jaro_distance(original, other), other]
        end
      end

      # :nodoc:
      def self.jaro_distance(original, other)
        JaroWinkler.jaro_distance(
          normalize_string(original),
          normalize_string(other),
          StubRequests.config.jaro_options,
        )
      end

      # :nodoc:
      def self.normalize_string(value)
        value.to_s.gsub(FILTER_REGEX, "")
      end
    end
  end
end

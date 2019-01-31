# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Provides convenience methods for hashes
  #
  module HashUtil
    #
    # Removes all entries with nil values (first level only)
    #
    # @param [Hash] options the hash to compact
    #
    # @return [Hash, nil] Returns
    #
    # @yieldparam [Hash] compacted the hash without nils
    # @yieldreturn [void]
    def self.compact(options)
      return if options.blank?

      compacted = options.delete_if { |_, val| val.blank? }
      yield compacted if compacted.present?
    end
  end
end

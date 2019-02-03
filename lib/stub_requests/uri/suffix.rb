# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module URI organizes all gem logic regarding URI
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module URI
    #
    # Module Suffix deals with validating {URI} suffix
    #
    module Suffix
      #
      # @return [RegExp] a pattern used for matching HTTP(S) ports
      PORT_REGEX = %r{:(\d+)/}.freeze

      #
      # Checks if the host has a valid suffix
      #
      # @param [String] host a string to check
      #
      # @return [true,false]
      #
      def self.valid?(host)
        PublicSuffix.valid?(host, default_rule: nil)
      end
    end
  end
end

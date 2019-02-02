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
    # Module Scheme handles validation of {URI} schemes
    #
    module Scheme
      #
      # @return [Array<String>] a list of valid HTTP schemes
      SCHEMES = %w[http https].freeze

      #
      # Checks if the scheme is valid
      #
      # @param [String] scheme a string with the URI scheme to check
      #
      # @return [true,false]
      #
      def self.valid?(scheme)
        SCHEMES.include?(scheme.to_s)
      end
    end
  end
end

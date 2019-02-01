# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Provides convenience methods for URI
  #
  module URI
    #
    # Validator provides functionality for validating a {::URI}
    #
    class Validator
      #
      # Validates a URI
      #
      # @param [String] uri a full uri with path
      #
      # @return [true, false]
      #
      def self.valid?(uri)
        new(uri).valid?
      end

      #
      # @!attribute [r] uri
      #   @return [String] a complete URI
      attr_reader :uri
      #
      # @!attribute [r] host
      #   @return [String] the URI host
      attr_reader :host
      #
      # @!attribute [r] scheme
      #   @return [String] the URI scheme
      attr_reader :scheme

      #
      # Initialize a new instance of {Validator}
      #
      # @raise [InvalidUri] when URI can't be parsed
      #
      # @param [String] uri the full URI
      #
      #
      def initialize(uri)
        @uri    = ::URI.parse(uri)
        @host   = @uri.host
        @scheme = @uri.scheme
      rescue ::URI::InvalidURIError
        raise InvalidUri, uri
      end

      #
      # Checks if a URI is valid
      #
      #
      # @return [true,false] <description>
      #
      def valid?
        URI::Scheme.valid?(scheme) && URI::Suffix.valid?(host)
      end
    end
  end
end

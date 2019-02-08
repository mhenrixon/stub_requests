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
    # Builder constructs and validates URIs
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    #
    class Builder
      #
      # @return [Regexp] A pattern for matching url segment keys
      URI_KEY = %r{(:[a-zA-Z_]+)}.freeze

      #
      # Convenience method to avoid .new.build
      #
      #
      # @raise [UriSegmentMismatch] when there are unused URI segments
      # @raise [UriSegmentMismatch] when the template have unplaced URI segments
      #
      # @param [String] the URI to the service endpoint
      # @param [Hash<Symbol>] route_params a list of uri_replacement keys
      #
      # @return [String] a validated URI string
      #
      def self.build(uri, route_params = {})
        new(uri, route_params).build
      end

      #
      # @!attribute [r] uri
      #   @return [String] the URI to the service endpoint
      attr_reader :uri
      #
      # @!attribute [r] route_params
      #   @return [Hash<Symbol] a hash with keys matching the {#template}
      attr_reader :route_params
      #
      # @!attribute [r] actual_keys
      #   @return [Array<String>] a list with actual {#route_params} keys
      attr_reader :actual_keys
      #
      # @!attribute [r] expected_keys
      #   @return [Array<String>] a list of expected route keys
      attr_reader :expected_keys

      #
      # Initializes a new Builder
      #
      #
      # @param [String] uri the URI used to reach the service
      # @param [Hash<Symbol>] route_params a list of uri_replacement keys
      #
      def initialize(uri, route_params = {})
        @uri           = +uri
        @route_params  = route_params.to_route_param
        @actual_keys   = @route_params.keys
        @expected_keys = uri.scan(URI_KEY).flatten.uniq
      end

      #
      # Builds a URI string
      #
      #
      # @raise [UriSegmentMismatch] when there are unused URI segments
      # @raise [UriSegmentMismatch] when the template have unplaced URI segments
      #
      # @return [String] a validated URI string
      #
      def build
        validate_uri_has_route_params!
        build_uri
        validate_uri

        uri
      end

      private

      def validate_uri_has_route_params!
        return if validate_uri_has_route_params
        raise UriSegmentMismatch,
              "The URI (#{uri}) expected the following route params `#{expected_keys.join(', ')}` but received `#{actual_keys.join(', ')}`"
      end

      def validate_uri_has_route_params
        expected_keys.sort == actual_keys.sort
      end

      def build_uri
        route_params.each do |key, value|
          replace_key(key, value)
        end.compact
      end

      def replace_key(key, value)
        return unless uri.include?(key)

        actual_keys.delete(key)
        expected_keys.delete(key)
        uri.gsub!(key, value.to_s)
      end

      #
      # Validates {#uri} is valid
      #
      #
      # @return [true, false]
      #
      def validate_uri
        StubRequests::URI::Validator.valid?(uri)
      rescue InvalidUri
        StubRequests.logger.warn("URI (#{uri}) is not valid.")
        false
      end

      #
      # Raise exception when {#validate_uri} is false
      #
      # @see #validate_uri
      #
      # @raise [InvalidUri] when #{uri} is invalid
      #
      # @return [void]
      #
      # :nocov:
      # :nodoc:
      def validate_uri!
        raise InvalidUri, uri unless validate_uri
      end
    end
  end
end

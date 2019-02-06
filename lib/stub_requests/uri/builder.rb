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
    # :reek:TooManyInstanceVariables { max_instance_variables: 6 }
    class Builder
      #
      # @return [Regexp] A pattern for matching url segment keys
      URL_SEGMENT_REGEX = /(:\w+)/.freeze

      #
      # Convenience method to avoid .new.build
      #
      #
      # @raise [UriSegmentMismatch] when there are unused URI segments
      # @raise [UriSegmentMismatch] when the template have unplaced URI segments
      #
      # @param [String] host the URI used to reach the service
      # @param [String] template the endpoint template
      # @param [Hash<Symbol>] route_params a list of uri_replacement keys
      #
      # @return [String] a validated URI string
      #
      def self.build(host, template, route_params = {})
        new(host, template, route_params).build
      end

      #
      # @!attribute [r] uri
      #   @return [String] the request host {Service#service_uri}
      attr_reader :host
      #
      # @!attribute [r] template
      #   @return [String] a string template for the endpoint
      attr_reader :template
      #
      # @!attribute [r] path
      #   @return [String] a valid URI path
      attr_reader :path
      #
      # @!attribute [r] route_params
      #   @return [Hash<Symbol] a hash with keys matching the {#template}
      attr_reader :route_params
      #
      # @!attribute [r] unused
      #   @return [Array<String>] a list with unused {#route_params}
      attr_reader :unused
      #
      # @!attribute [r] unreplaced
      #   @return [Array<String>] a list of uri_segments that should have been replaced
      attr_reader :unreplaced

      #
      # Initializes a new Builder
      #
      #
      # @param [String] host the URI used to reach the service
      # @param [String] template the endpoint template
      # @param [Hash<Symbol>] route_params a list of uri_replacement keys
      #
      def initialize(host, template, route_params = {})
        @host         = +host
        @template     = +template
        @path         = +@template.dup
        @route_params = route_params.to_route_param
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
        build_uri
        run_validations

        uri
      end

      private

      def build_uri
        replace_segments
        parse_unreplaced_segments
      end

      def uri
        @uri ||= [host, path].join("/")
      end

      def run_validations
        validate_route_params_used
        validate_route_keys_replaced
        validate_uri
      end

      #
      # Replaces the URI segments with the arguments in route_params
      #
      #
      # @return [Array] an list with unused route_params
      #
      def replace_segments
        @unused = route_params.map do |key, value|
          next key unless path.include?(key)

          path.gsub!(key, value.to_s)
          next
        end.compact
      end

      #
      # Validates that all route_params have been used
      #
      #
      # @raise [UriSegmentMismatch] when there are unused route_params
      #
      # @return [void]
      #
      def validate_route_params_used
        return if replacents_used?

        raise UriSegmentMismatch,
              "The URI segment(s) [#{unused.join(',')}] are missing in template (#{path})"
      end

      #
      # Checks that no route_params are left
      #
      #
      # @return [true,false]
      #
      def replacents_used?
        unused.none?
      end

      #
      # Validates that all URI segments have been replaced in {#path}
      #
      #
      # @raise [UriSegmentMismatch] when the path have unplaced URI segments
      #
      # @return [void]
      #
      def validate_route_keys_replaced
        return if route_keys_replaced?

        raise UriSegmentMismatch,
              "The URI segment(s) [#{unreplaced.join(',')}]" \
              " were not replaced in template (#{path})." \
              " Given route_params=[#{route_params.keys.join(',')}]"
      end

      #
      # Checks that all URI keys were replaced
      #
      #
      # @return [true,false]
      #
      def route_keys_replaced?
        unreplaced.none?
      end

      #
      # Parses out all unused URI segments
      #
      #
      # @return [Array<String>] a list of not replaced uri_segments
      #
      def parse_unreplaced_segments
        @unreplaced = URL_SEGMENT_REGEX.match(path).to_a.uniq
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

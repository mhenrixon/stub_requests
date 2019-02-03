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
      # @param [Hash<Symbol>] replacements a list of uri_replacement keys
      #
      # @return [String] a validated URI string
      #
      def self.build(host, template, replacements = {})
        new(host, template, replacements).build
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
      # @!attribute [r] replacements
      #   @return [Hash<Symbol] a hash with keys matching the {#template}
      attr_reader :replacements
      #
      # @!attribute [r] unused
      #   @return [Array<String>] a list with unused {#replacements}
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
      # @param [Hash<Symbol>] replacements a list of uri_replacement keys
      #
      def initialize(host, template, replacements = {})
        @host         = +host
        @template     = +template
        @path         = +@template.dup
        @replacements = replacements
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
        validate_replacements_used
        validate_segments_replaced
        validate_uri
      end

      #
      # Replaces the URI segments with the arguments in replacements
      #
      #
      # @return [Array] an list with unused replacements
      #
      def replace_segments
        @unused = replacements.map do |key, value|
          uri_segment = ":#{key}"
          if path.include?(uri_segment)
            path.gsub!(uri_segment.to_s, value.to_s)
            next
          else
            uri_segment
          end
        end.compact
      end

      #
      # Validates that all replacements have been used
      #
      #
      # @raise [UriSegmentMismatch] when there are unused replacements
      #
      # @return [void]
      #
      def validate_replacements_used
        return if replacents_used?

        raise UriSegmentMismatch,
              "The URI segment(s) [#{unused.join(',')}] are missing in template (#{path})"
      end

      #
      # Checks that no replacements are left
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
      def validate_segments_replaced
        return if segments_replaced?

        raise UriSegmentMismatch,
              "The URI segment(s) [#{unreplaced.join(',')}]" \
              " were not replaced in template (#{path})." \
              " Given replacements=[#{segment_keys.join(',')}]"
      end

      def segment_keys
        @segment_keys ||= replacements.keys.map { |segment_key| ":#{segment_key}" }
      end

      #
      # Checks that all URI segments were replaced
      #
      #
      # @return [true,false]
      #
      def segments_replaced?
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

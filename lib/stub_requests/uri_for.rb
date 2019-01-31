# frozen_string_literal: true

require "addressable/uri"
require "public_suffix"

module StubRequests
  #
  # Module UriFor provides constructing URI templates to full valid URI's
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module UriFor
    extend self

    def self.included(base)
      base.send(:extend, self)
    end

    SCHEMES           = %w[http https].freeze
    URL_SEGMENT_REGEX = /(:\w+)/.freeze

    #
    # Converts the URI template into full service URI
    #
    # @param [String] service_uri the  service uri
    # @param [String] uri_template the URI template with replaceable URI segments
    # @param [optional, Hash<Symbol>, Hash<String>] uri_replacements to use for the :uri_template
    #
    # @example Construct a valid uri
    #   UriFor.uri_for(
    #     "http://service-name:9292/internal",
    #     "persons/:person_id/identifications",
    #     { person_id: "abcdefabper" }) #=> "http://service-name:9292/internal/persons/abcdefabper/identifications
    #
    # @raise [UriSegmentMismatch] if uri_replacements passed in are not used
    # @raise [UriSegmentMismatch] if the uri has unreplacded uri segments
    #
    # @return [String] the full uri to the endpoint,
    #   `"http://service-name:9292/internal/persons/abcdefabper/identifications"`
    #
    def uri_for(service_uri, uri_template, uri_replacements)
      uri                 = +uri_template
      unused_replacements = replace_uri_segments(uri, uri_template, uri_replacements)

      validate_replacements_used!(uri_template, unused_replacements)
      validate_segments_replaced!(uri, uri_replacements)

      warn_about_invalid_uri([service_uri, uri].join("/"))
    end

    #
    # Validates that all uri_replacements have been used
    #
    # @param [String, Symbol] uri_template an endpoint uri_template
    # @param [Array] unused_uri_replacements a list of not used uri_replacements
    #
    # @raise [UriSegmentMismatch] when there are unused uri segments
    #
    # @return [nil] when all is good
    #
    def validate_replacements_used!(uri_template, unused_replacements)
      return if unused_replacements.none?

      raise UriSegmentMismatch,
            "The uri segment(s) [#{unused_replacements.join(',')}] are missing in uri_template (#{uri_template})"
    end

    #
    # Validates that all URI segments have been replaced in uri_template
    #
    # @param [String, Symbol] uri_template the endpoint uri_template
    # @param [Array] uri_replacements a list of uri_replacement keys
    #
    # @raise [UriSegmentMismatch] when the uri_template have unreplaced uri segments
    #
    # @return [nil] when all is good
    #
    def validate_segments_replaced!(uri_template, uri_replacements)
      unreplaced_segments = parse_unreplaced_segments(uri_template)
      return if unreplaced_segments.none?

      raise UriSegmentMismatch,
            "The uri segment(s) [#{unreplaced_segments.join(',')}]" \
            " were not replaced in uri_template (#{uri_template})." \
            " Given uri_replacements=[#{uri_replacements.keys.join(',')}]"
    end

    private

    def replace_uri_segments(uri, uri_template, uri_replacements)
      uri_replacements.map do |key, value|
        uri_segment = ":#{key}"
        if uri_template.include?(uri_segment)
          uri.gsub!(uri_segment.to_s, value.to_s)
          next
        else
          uri_segment
        end
      end.compact
    end

    def parse_unreplaced_segments(uri_template)
      URL_SEGMENT_REGEX.match(uri_template).to_a.uniq
    end

    def warn_about_invalid_uri(uri)
      StubRequests.logger.warn("Uri (#{uri}) is not valid.") unless valid_uri?(uri)
      uri
    end

    def valid_uri?(value)
      return unless (uri = URI.parse(value))

      host   = uri.host
      scheme = uri.scheme

      valid_scheme?(host, scheme) && valid_suffix?(host)
    rescue URI::InvalidURIError
      false
    end

    def valid_scheme?(host, scheme)
      host && scheme && SCHEMES.include?(scheme)
    end

    def valid_suffix?(host)
      host && PublicSuffix.valid?(host, default_rule: nil)
    end
  end
end

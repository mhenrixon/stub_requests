# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module WebMock extends WebMock with more functionality
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module WebMock
    #
    # Module Builder is responsible for building WebMock::RequestStub's
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    class Builder
      include HashUtil

      #
      # Builds and registers a WebMock::RequestStub
      #
      #
      # @param [Symbol] verb a HTTP verb/method
      # @param [String] uri a URI to call
      # @param [Hash<Symbol>] options request/response options for Webmock::RequestStub
      #
      # @yield a callback to eventually yield to the caller
      #
      # @return [WebMock::RequestStub] the registered stub
      #
      def self.build(verb, uri, options = {}, &callback)
        new(verb, uri, options, &callback).build
      end

      #
      # @!attribute [r] request_stub
      #   @return [WebMock::RequestStub] a stubbed webmock request
      attr_reader :request_stub
      #
      # @!attribute [r] options
      #   @return [Hash<Symbol>] options for the stub_request
      attr_reader :options
      #
      # @!attribute [r] callback
      #   @return [Block] call back when given a block
      attr_reader :callback

      #
      # Initializes a new instance of
      #
      #
      # @param [Symbol] verb a HTTP verb/method
      # @param [String] uri a URI to call
      # @param [Hash<Symbol>] options request/response options for Webmock::RequestStub
      #
      # @yield a block to eventually yield to the caller
      #
      def initialize(verb, uri, options = {}, &callback)
        @request_stub = ::WebMock::RequestStub.new(verb, uri)
        @options      = options
        @callback     = callback
      end

      #
      # Prepares a WebMock::RequestStub and registers it in WebMock
      #
      #
      # @return [WebMock::RequestStub] the registered stub
      #
      def build
        if callback.present?
          Docile.dsl_eval(request_stub, &callback)
        else
          prepare_mock_request
        end

        request_stub
      end

      private

      def prepare_mock_request
        prepare_with
        prepare_to_return
        prepare_to_raise
        request_stub.to_timeout if options[:timeout]
        request_stub
      end

      def prepare_with
        HashUtil.compact(options[:request]) do |request_options|
          request_stub.with(request_options)
        end
      end

      def prepare_to_return
        HashUtil.compact(options[:response]) do |response_options|
          request_stub.to_return(response_options)
        end
      end

      def prepare_to_raise
        return unless (error = options[:error])

        request_stub.to_raise(*Array(error))
      end
    end
  end
end

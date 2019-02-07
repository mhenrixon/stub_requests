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
      #
      # Builds and registers a WebMock::RequestStub
      #
      #
      # @param [Symbol] verb a HTTP verb/method
      # @param [String] uri a URI to call
      #
      # @yield a callback to eventually yield to the caller
      #
      # @return [WebMock::RequestStub]
      #
      def self.build(verb, uri, &callback)
        new(verb, uri, &callback).build
      end

      #
      # @!attribute [r] webmock_stub
      #   @return [WebMock::RequestStub] a stubbed webmock request
      attr_reader :webmock_stub
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
      #
      # @yield a block to eventually yield to the caller
      #
      def initialize(verb, uri, &callback)
        @webmock_stub = ::WebMock::RequestStub.new(verb, uri)
        @callback     = callback
      end

      #
      # Prepares a WebMock::RequestStub and registers it in WebMock
      #
      #
      # @return [WebMock::RequestStub] the registered stub
      #
      def build
        Docile.dsl_eval(webmock_stub, &callback) if callback.present?
        webmock_stub
      end
    end
  end
end

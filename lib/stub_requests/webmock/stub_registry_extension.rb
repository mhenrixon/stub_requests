# frozen_string_literal: true

#
# Abstraction over WebMock to reduce duplication
#
# @author Mikael Henriksson <mikael@zoolutions.se>
# @since 0.1.0
#
module StubRequests
  #
  # Module WebMock provides a namespace for extensions of WebMock
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.2
  #
  module WebMock
    #
    # Module StubRegistryExtension extends WebMock::StubRegistry with
    #   recording of when a response was found and used for a WebMock::RequestStub
    #
    # @author Mikael Henriksson <mikael@zoolutions.se>
    # @since 0.1.2
    #
    module StubRegistryExtension
      # :nodoc:
      def self.included(base)
        base.class_eval do
          alias_method :request_stub_for_orig, :request_stub_for
          alias_method :request_stub_for, :request_stub_for_ext
        end
      end

      private

      def request_stub_for_ext(request_signature)
        request_stub = request_stub_for_orig(request_signature)
        return request_stub unless request_stub

        Metrics::Registry.instance.mark_as_responded(request_stub)
        request_stub
      end
    end
  end
end

::WebMock::StubRegistry.send(:include, StubRequests::WebMock::StubRegistryExtension)

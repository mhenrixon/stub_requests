# frozen_string_literal: true

module StubRequests
  module WebMock
    module StubRegistryExtension
      def self.included(base)
        base.class_eval do
          alias_method :request_stub_for_orig, :request_stub_for
          alias_method :request_stub_for, :request_stub_for_ext
        end
      end

      private

      def request_stub_for_ext(request_signature)
        if (request_stub = request_stub_for_orig(request_signature))
          record = Metrics::Registry.instance.find_record(request_stub).first
          binding.pry
          record&.mark_as_responded!
        end
        request_stub
      end
    end
  end
end

::WebMock::StubRegistry.send(:include, StubRequests::WebMock::StubRegistryExtension)

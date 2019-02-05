# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Metrics do
  describe ".record" do
    subject(:record) { described_class.record(service, endpoint, request_stub) }

    let(:service)      { instance_spy(StubRequests::Service) }
    let(:endpoint)     { instance_spy(StubRequests::Endpoint) }
    let(:request_stub) { instance_spy(WebMock::RequestStub) }
    let(:registry)     { StubRequests::Metrics::Registry.instance }

    before do
      allow(registry).to receive(:record)
      record
    end

    context "when StubRequests.config.record_metrics is true", record_metrics: true do
      it "delegates to the registry instance" do
        expect(registry).to have_received(:record).with(service, endpoint, request_stub)
      end
    end

    context "when StubRequests.config.record_metrics is false", record_metrics: false do
      it "does not call registry.record" do
        expect(registry).not_to have_received(:record)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Observable do
  let(:registry)        { described_class::Registry.instance }
  let(:registry_method) { nil }
  let(:service_id)      { :documents }
  let(:endpoint_id)     { :show }
  let(:verb)            { :any }

  before { allow(registry).to receive(registry_method) }

  describe ".subscribe_to" do
    subject! { described_class.subscribe_to(service_id, endpoint_id, verb, callback) }

    let(:registry_method) { :subscribe }
    let(:callback)        { ->(request) { p request } }

    it "delegates to Observable::Registry.instance" do
      expect(registry).to have_received(registry_method)
        .with(service_id, endpoint_id, verb, callback)
    end
  end

  describe ".unsubscribe_from" do
    subject! { described_class.unsubscribe_from(service_id, endpoint_id, verb) }

    let(:registry_method) { :unsubscribe }

    it "delegates to Observable::Registry.instance" do
      expect(registry).to have_received(registry_method)
        .with(service_id, endpoint_id, verb)
    end
  end

  describe ".notify_subscribers" do
    subject! { described_class.notify_subscribers(request) }

    let(:registry_method) { :notify_subscribers }
    let(:request)         { instance_spy(StubRequests::Metrics::Request) }

    it "delegates to Observable::Registry.instance" do
      expect(registry).to have_received(registry_method)
        .with(request)
    end
  end
end

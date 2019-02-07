# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::StubRegistry do
  let(:stub_registry)    { described_class.instance }
  let(:service_registry) { StubRequests::ServiceRegistry.instance }

  let(:service)  { service_registry.register(service_id, service_uri) }
  let(:endpoint) { service.register(endpoint_id, endpoint_verb, endpoint_path) }

  let(:service_id)            { :lists }
  let(:service_uri)           { "https://example.com/api/v6" }
  let(:endpoint_id)           { :show }
  let(:endpoint_verb)         { :get }
  let(:endpoint_path)         { "lists/:id" }
  let(:route_params)          { { id: id } }
  let(:id)                    { 10_346 }

  let(:webmock_stub) { StubRequests::API.__stub_endpoint(endpoint.id, route_params) }

  before do
    service_registry.reset
    stub_registry.reset
  end

  describe "#record" do
    subject(:record) { stub_registry.record(endpoint_id, webmock_stub) }

    before do
      service_registry.register(service_id, service_uri)
    end

    context "when StubRequests.config.record_stubs is true", record_stubs: true do
      it { is_expected.to be_a(StubRequests::RequestStub) }

      its(:service_id)  { is_expected.to eq(service_id) }
      its(:endpoint_id) { is_expected.to eq(endpoint_id) }
      its(:verb)        { is_expected.to eq(endpoint_verb) }
      its(:path)        { is_expected.to eq(endpoint_path) }
      its(:request_uri) { is_expected.to eq("https://example.com/api/v6/lists/#{id}") }
    end

    context "when StubRequests.config.record_stubs is false", record_stubs: false do
      it { is_expected.to eq(nil) }
    end
  end

  describe "#mark_as_responded", record_stubs: true do
    subject(:mark_as_responded) { stub_registry.mark_as_responded(webmock_stub) }

    let(:request_stub) { stub_registry.record(endpoint_id, webmock_stub) }

    context "when no stubs are registered" do
      it { is_expected.to eq(nil) }
    end

    context "when stubs are registered" do
      before { request_stub }

      it! { is_expected.to change(request_stub, :responded_at).from(nil) }
    end
  end
end

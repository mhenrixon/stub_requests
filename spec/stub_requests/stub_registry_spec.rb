# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::StubRegistry do
  let(:stub_registry)    { described_class.instance }
  let(:service_registry) { StubRequests::ServiceRegistry.instance }

  let(:service)  { service_registry.register(service_id, service_uri) }
  let(:endpoint) { service.endpoints.register(endpoint_id, endpoint_verb, endpoint_path) }

  let(:service_id)            { :lists }
  let(:service_uri)           { "https://example.com/api/v6" }
  let(:endpoint_id)           { :show }
  let(:endpoint_verb)         { :get }
  let(:endpoint_path) { "lists/:id" }
  let(:route_params)      { { id: id } }
  let(:id)                    { 10_346 }

  let(:request_stub) { StubRequests::ServiceRegistry.__stub_endpoint(service.id, endpoint.id, route_params) }

  describe ".record" do
    subject(:record) { described_class.record(service, endpoint, request_stub) }

    let(:service)      { instance_spy(StubRequests::Service) }
    let(:endpoint)     { instance_spy(StubRequests::Endpoint) }
    let(:request_stub) { instance_spy(WebMock::RequestStub) }
    let(:registry)     { StubRequests::StubRegistry.instance }

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

  before do
    service_registry.reset
    stub_registry.reset
  end

  describe "#record" do
    subject(:record) { stub_registry.record(service, endpoint, request_stub) }

    before do
      service_registry.register(service_id, service_uri)
    end

    it { is_expected.to be_a(StubRequests::EndpointStub) }

    its(:service_id)   { is_expected.to eq(service_id) }
    its(:endpoint_id)  { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(endpoint_verb) }
    its(:path) { is_expected.to eq("#{service_uri}/#{endpoint_path}") }
    its(:stubs)        { is_expected.not_to be_empty }
    its("stubs.size")  { is_expected.to eq(1) }
  end

  describe "#find_request_stub" do
    subject(:find_request_stub) { stub_registry.find_request_stub(request_stub) }

    context "when no stubs are registered" do
      it { is_expected.to eq(nil) }
    end

    context "when stubs are registered" do
      before { stub_registry.record(service, endpoint, request_stub) }

      it { is_expected.to be_a(StubRequests::RequestStub) }

      its(:verb)          { is_expected.to eq(endpoint_verb) }
      its(:uri)           { is_expected.to eq("https://example.com/api/v6/lists/#{id}") }
      its(:request_stub)  { is_expected.to eq(request_stub) }
      its(:recorded_at)   { is_expected.to be_a(Time) }
      its(:recorded_from) { is_expected.to eq(RSpec.current_example.metadata[:location]) }
      its(:responded_at)  { is_expected.to eq(nil) }
    end
  end

  describe "#mark_as_responded" do
    subject(:mark_as_responded) { stub_registry.mark_as_responded(request_stub) }

    let(:request) { stub_registry.find_request_stub(request_stub) }

    context "when no stubs are registered" do
      it { is_expected.to eq(nil) }
    end

    context "when stubs are registered" do
      before { stub_registry.record(service, endpoint, request_stub) }

      it! { is_expected.to change(request, :responded_at).from(nil) }
    end
  end
end

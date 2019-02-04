# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Metrics::Registry do
  include StubRequests::API

  let(:metrics_registry) { described_class.instance }
  let(:service_registry) { StubRequests::Registration::Registry.instance }

  let(:service)  { service_registry.register(service_id, service_uri) }
  let(:endpoint) { service.endpoints.register(endpoint_id, endpoint_verb, endpoint_uri_template) }

  let(:service_id)            { :lists }
  let(:service_uri)           { "https://example.com/api/v6" }
  let(:endpoint_id)           { :show }
  let(:endpoint_verb)         { :get }
  let(:endpoint_uri_template) { "lists/:id" }
  let(:uri_replacements)      { { id: id } }
  let(:id)                    { 10_346 }

  let(:request_stub) { StubRequests::Registration.__stub_endpoint(service.id, endpoint.id, uri_replacements) }

  before do
    service_registry.reset
    metrics_registry.reset
  end

  describe "#record" do
    subject(:record) { metrics_registry.record(service, endpoint, request_stub) }

    before do
      register_service(service_id, service_uri)
    end

    it { is_expected.to be_a(StubRequests::Metrics::Endpoint) }

    its(:service_id)     { is_expected.to eq(service_id) }
    its(:endpoint_id)    { is_expected.to eq(endpoint_id) }
    its(:verb)           { is_expected.to eq(endpoint_verb) }
    its(:uri_template)   { is_expected.to eq("#{service_uri}/#{endpoint_uri_template}") }
    its(:requests)       { is_expected.not_to be_empty }
    its("requests.size") { is_expected.to eq(1) }
  end

  describe "#find_request" do
    subject(:find_request) { metrics_registry.find_request(request_stub) }

    context "when no stats are recorded" do
      it { is_expected.to eq(nil) }
    end

    context "when stats have been recorded" do
      before { metrics_registry.record(service, endpoint, request_stub) }

      it { is_expected.to be_a(StubRequests::Metrics::Request) }

      its(:verb)          { is_expected.to eq(endpoint_verb) }
      its(:uri)           { is_expected.to eq("https://example.com/api/v6/lists/#{id}") }
      its(:request_stub)  { is_expected.to eq(request_stub) }
      its(:recorded_at)   { is_expected.to be_a(Time) }
      its(:recorded_from) { is_expected.to eq(RSpec.current_example.metadata[:location]) }
      its(:responded_at)  { is_expected.to eq(nil) }
    end
  end

  describe "#mark_as_responded" do
    subject(:mark_as_responded) { metrics_registry.mark_as_responded(request_stub) }

    let(:request) { metrics_registry.find_request(request_stub) }

    context "when no stats are recorded" do
      it { is_expected.to eq(nil) }
    end

    context "when stats have been recorded" do
      before { metrics_registry.record(service, endpoint, request_stub) }

      it! { is_expected.to change(request, :responded_at).from(nil) }
    end
  end
end

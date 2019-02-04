# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Metrics::Request do
  let(:request) { described_class.new(endpoint, request_stub) }

  let(:endpoint)      { StubRequests::Metrics::Endpoint.new(service, reg_endpoint) }
  let(:request_stub)  { WebMock::RequestStub.new(:get, "http://google.com") }
  let(:service)       { StubRequests::Registration::Service.new(service_id, service_uri) }
  let(:reg_endpoint)  { StubRequests::Registration::Endpoint.new(endpoint_id, verb, uri_template) }
  let(:uri)           { URI.for_service_endpoint(service, reg_endpoint, id: "first") }

  let(:service_id)   { :google_documents }
  let(:service_uri)  { "http://google.com" }

  let(:endpoint_id)  { :show }
  let(:verb)         { :get }
  let(:uri_template) { "documents/:id" }

  describe ".properties" do
    subject(:properties) { described_class.properties }

    let(:expected_properties) do
      {
        endpoint: { default: nil, type: [StubRequests::Metrics::Endpoint] },
        verb: { default: nil, type: [Symbol] },
        uri: { default: nil, type: [String] },
        request_stub: { default: nil, type: [WebMock::RequestStub] },
        recorded_at: { default: nil, type: [Time] },
        recorded_from: { default: nil, type: [String] },
        responded_at: { default: nil, type: [Time] },
      }
    end

    it { is_expected.to eq(expected_properties) }
  end

  describe "#initialize" do
    subject { request }

    let(:request_pattern) { request_stub.request_pattern }

    its(:verb)          { is_expected.to eq(request_pattern.method_pattern.to_s.to_sym) }
    its(:uri)           { is_expected.to eq(request_pattern.uri_pattern.to_s) }
    its(:request_stub)  { is_expected.to eq(request_stub) }
    its(:recorded_at)   { is_expected.to be_a(Time) }
    its(:recorded_from) { is_expected.to eq(RSpec.current_example.metadata[:location]) }
    its(:responded_at)  { is_expected.to eq(nil) }
  end

  describe "#mark_as_responded" do
    subject { request.mark_as_responded }

    it! { is_expected.to change(request, :responded_at).from(nil) }
  end
end

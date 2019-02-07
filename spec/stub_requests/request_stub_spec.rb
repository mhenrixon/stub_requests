# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::RequestStub do
  let(:request)      { described_class.new(endpoint_id, webmock_stub) }
  let(:webmock_stub) { WebMock::RequestStub.new(:get, "http://google.com") }
  let(:uri)          { URI::Builder.build(service_uri, path, id: "first") }

  let(:service_id)   { :google_documents }
  let(:service_uri)  { "http://google.com" }
  let(:endpoint_id)  { :show }
  let(:verb)         { :get }
  let(:path)         { "documents/:id" }
  let(:endpoint_attributes) do
    {
      endpoint_id: endpoint_id,
      service_id: service_id,
      service_uri: service_uri,
      verb: verb,
      path: path,
    }
  end

  describe ".properties" do
    subject(:properties) { described_class.properties }

    let(:expected_properties) do
      {
        endpoint_id: { default: nil, type: [Symbol] },
        verb: { default: nil, type: [Symbol] },
        request_uri: { default: nil, type: [String] },
        webmock_stub: { default: nil, type: [WebMock::RequestStub] },
        recorded_at: { default: nil, type: [Time] },
        recorded_from: { default: nil, type: [String] },
        responded_at: { default: nil, type: [Time] },
      }
    end

    it { is_expected.to eq(expected_properties) }
  end

  describe "#initialize" do
    subject { request }

    let(:request_pattern) { webmock_stub.request_pattern }

    its(:verb)          { is_expected.to eq(request_pattern.method_pattern.to_s.to_sym) }
    its(:request_uri)   { is_expected.to eq(request_pattern.uri_pattern.to_s) }
    its(:webmock_stub)  { is_expected.to eq(webmock_stub) }
    its(:recorded_at)   { is_expected.to be_a(Time) }
    its(:recorded_from) { is_expected.to eq(RSpec.current_example.metadata[:location]) }
    its(:responded_at)  { is_expected.to eq(nil) }
  end

  describe "#mark_as_responded" do
    subject { request.mark_as_responded }

    it! { is_expected.to change(request, :responded_at).from(nil) }
  end
end

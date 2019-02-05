# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::API do
  let(:service_registry) { StubRequests::ServiceRegistry.instance }
  let(:service_id)       { :api }
  let(:service_uri)      { "https://api.com/v1" }
  let(:verb)             { :get }
  let(:uri)              { "http://service-less:9292/internal/accounts/acoolaccountuid" }
  let(:request_query)    { nil }
  let(:request_body)     { nil }
  let(:request_headers)  { nil }
  let(:response_status)  { 200 }
  let(:response_headers) { nil }
  let(:response_body)    { nil }
  let(:error)            { nil }
  let(:options) do
    {
      request: request_options,
      response: response_options,
      error: error,
    }
  end
  let(:request_options) do
    {
      query: request_query,
      body: request_body,
      headers: request_headers,
    }
  end
  let(:response_options) do
    {
      status: response_status,
      headers: response_headers,
      body: response_body,
    }
  end

  describe "#register_service" do
    subject(:register_service) do
      described_class.register_service(service_id, service_uri)
    end

    shared_examples "a successful registration" do
      it { is_expected.to be_a(StubRequests::Service) }

      its(:id)  { is_expected.to eq(service_id) }
      its(:uri) { is_expected.to eq(service_uri) }

      it! { is_expected.to change(service_registry, :count).by(1) }
    end

    it_behaves_like "a successful registration"

    context "when given a block" do
      specify { register_service { expect(self).to be_a(StubRequests::Endpoints) } }

      it_behaves_like "a successful registration"
    end
  end

  describe "#stub_endpoint" do
    subject(:stub_endpoint) do
      described_class.stub_endpoint(service_id, endpoint_id, uri_replacements, options)
    end

    let(:endpoint_id)      { :files }
    let(:verb)             { :get }
    let(:uri_template)     { "files/:file_id" }
    let(:uri_replacements) { { file_id: 100 } }
    let(:options)          { {} }
    let(:service)          { nil }
    let(:block)            { nil }

    context "when service is unregistered" do
      let(:error)   { StubRequests::ServiceNotFound }
      let(:message) { "Couldn't find a service with id=:api" }

      it! { is_expected.to raise_error(error, message) }
    end

    context "when service is registered" do
      let!(:service) { described_class.register_service(service_id, service_uri) }

      context "when endpoint is registered" do
        let!(:endpoint) { service.endpoints.register(endpoint_id, verb, uri_template) } # rubocop:disable RSpec/LetSetup

        it { is_expected.to be_a(WebMock::RequestStub) }
      end

      context "when given a block" do
        let!(:endpoint) { service.endpoints.register(endpoint_id, verb, uri_template) } # rubocop:disable RSpec/LetSetup

        it "yields the stub to the block" do
          stub_endpoint do |stub|
            expect(stub).to be_a(WebMock::RequestStub)
          end
        end
      end

      context "when endpoint is unregistered" do
        let(:error)   { StubRequests::EndpointNotFound }
        let(:message) { "Couldn't find an endpoint with id=:files" }

        it! { is_expected.to raise_error(error, message) }
      end
    end
  end

  describe "#subscribe_to" do
    subject(:subscribe_to) do
      described_class.subscribe_to(service_id, endpoint_id, verb, callback)
    end

    let(:service_id)  { :random_api }
    let(:endpoint_id) { :files }
    let(:verb)        { :get }
    let(:callback)    { -> {} }

    before do
      allow(StubRequests::Observable).to receive(:subscribe_to)
      subscribe_to
    end

    it "delegates to StubRequests::Observable.subscribe_to" do
      expect(StubRequests::Observable).to have_received(:subscribe_to)
        .with(service_id, endpoint_id, verb, callback)
    end
  end

  describe "#unsubscribe_from" do
    subject(:unsubscribe_from) do
      described_class.unsubscribe_from(service_id, endpoint_id, verb)
    end

    let(:service_id)  { :random_api }
    let(:endpoint_id) { :files }
    let(:verb)        { :get }

    before do
      allow(StubRequests::Observable).to receive(:unsubscribe_from)
      unsubscribe_from
    end

    it "delegates to StubRequests::Observable.unsubscribe_from" do
      expect(StubRequests::Observable).to have_received(:unsubscribe_from)
        .with(service_id, endpoint_id, verb)
    end
  end
end

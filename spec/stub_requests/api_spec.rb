# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::API do
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

  describe ".stub_endpoint" do
    subject(:stub_endpoint) do
      described_class.stub_endpoint(service_id, endpoint_id, uri_replacements, options)
    end

    let(:service_id)       { :api }
    let(:service_uri)      { "https://api.com/v1" }
    let(:endpoint_id)      { :files }
    let(:verb)             { :get }
    let(:uri_template)     { "files/:file_id" }
    let(:uri_replacements) { { file_id: 100 } }
    let(:options)          { {} }
    let(:service)          { nil }
    let(:block)            { nil }

    context "when service is registered" do
      let!(:service) { described_class.register_service(service_id, service_uri) }

      context "when endpoint is registered" do
        let!(:endpoint) { service.register_endpoint(endpoint_id, verb, uri_template) } # rubocop:disable RSpec/LetSetup

        it { is_expected.to be_a(WebMock::RequestStub) }
      end

      context "when given a block" do
        let!(:endpoint) { service.register_endpoint(endpoint_id, verb, uri_template) } # rubocop:disable RSpec/LetSetup

        it "yields the stub to the block" do
          stub_endpoint do |stub|
            expect(stub).to be_a(WebMock::RequestStub)
          end
        end
      end

      context "when endpoint is unregistered" do
        specify do
          expect { stub_endpoint }.to raise_error(
            StubRequests::EndpointNotFound,
            "Couldn't find an endpoint with id=:files",
          )
        end
      end
    end

    context "when service is unregistered" do
      specify do
        expect { stub_endpoint }.to raise_error(
          StubRequests::ServiceNotFound,
          "Couldn't find a service with id=:api",
        )
      end
    end
  end

  describe ".create_webmock_stub" do
    subject(:create_webmock_stub) do
      described_class.create_webmock_stub(verb, uri, options)
    end

    it { is_expected.to be_a(WebMock::RequestStub) }

    describe "configuration of WebMock::RequestStub" do
      let(:request_stub) { instance_spy(WebMock::RequestStub) }

      before do
        allow(WebMock::RequestStub).to receive(:new).with(verb, uri).and_return(request_stub)
        allow(request_stub).to receive(:with)
        allow(request_stub).to receive(:to_return)
      end

      context "when given request query" do
        let(:request_query) { { abd: :def } }

        it "configures webmock with query" do
          create_webmock_stub
          expect(request_stub).to have_received(:with).with(a_hash_including(query: request_query))
        end
      end

      context "when given request headers" do
        let(:request_headers) { { "Accept" => "N/A" } }

        it "configures webmock with request_headers" do
          create_webmock_stub
          expect(request_stub).to have_received(:with).with(a_hash_including(headers: request_headers))
        end
      end

      context "when given request body" do
        let(:request_body) { { rock: "'n'roll" } }

        it "configures webmock with request_body" do
          create_webmock_stub
          expect(request_stub).to have_received(:with).with(a_hash_including(body: request_body))
        end
      end

      context "when given a response status" do
        let(:response_status) { 500 }

        it "configures webmock with response_status" do
          create_webmock_stub
          expect(request_stub).to have_received(:to_return).with(a_hash_including(status: response_status))
        end
      end

      context "when given response headers" do
        let(:response_headers) { { "Accept" => "application/crashes" } }

        it "configures webmock with response_headers" do
          create_webmock_stub
          expect(request_stub).to have_received(:to_return).with(a_hash_including(headers: response_headers))
        end
      end

      context "when given response body" do
        let(:response_body) { { float: :my_boat } }

        it "configures webmock with response_body" do
          create_webmock_stub
          expect(request_stub).to have_received(:to_return).with(a_hash_including(body: response_body))
        end
      end
    end
  end

  describe ".prepare_request" do
    subject { described_class.prepare_request(request_options) }

    let(:request_query)   { "random=value" }
    let(:request_headers) { { "Accept" => "application/json" } }
    let(:request_body)    { "No Content" }

    it { is_expected.to eq(query: request_query, headers: request_headers, body: request_body) }

    context "when query is nil" do
      let(:request_query) { nil }

      it { is_expected.to eq(headers: request_headers, body: request_body) }
    end

    context "when request_headers is nil" do
      let(:request_headers) { nil }

      it { is_expected.to eq(query: request_query, body: request_body) }
    end

    context "when request_body is nil" do
      let(:request_body) { nil }

      it { is_expected.to eq(query: request_query, headers: request_headers) }
    end

    context "when all arguments are nil" do
      let(:request_query)           { nil }
      let(:request_headers)         { nil }
      let(:request_body)            { nil }

      it { is_expected.to eq({}) }
    end
  end

  describe ".prepare_response" do
    subject { described_class.prepare_response(response_options) }

    let(:response_status)  { 204 }
    let(:response_headers) { { "Accept" => "application/json" } }
    let(:response_body)    { "No Content" }

    it { is_expected.to eq(status: response_status, headers: response_headers, body: response_body) }

    context "when response_status is nil" do
      let(:response_status) { nil }

      it { is_expected.to eq(headers: response_headers, body: response_body) }
    end

    context "when response_headers is nil" do
      let(:response_headers) { nil }

      it { is_expected.to eq(status: response_status, body: response_body) }
    end

    context "when response_body is nil" do
      let(:response_body) { nil }

      it { is_expected.to eq(status: response_status, headers: response_headers) }
    end

    context "when all arguments are nil" do
      let(:response_status)  { nil }
      let(:response_headers) { nil }
      let(:response_body)    { nil }

      it { is_expected.to eq({}) }
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::WebMock::Builder do
  let(:builder)          { described_class.new(verb, uri, options) }
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

  describe "#build" do
    subject(:build) { builder.build }

    it { is_expected.to be_a(WebMock::RequestStub) }

    describe "configuration of WebMock::RequestStub" do
      let(:request_stub) { instance_spy(WebMock::RequestStub) }

      before do
        allow(WebMock::RequestStub).to receive(:new).with(verb, uri).and_return(request_stub)
        allow(request_stub).to receive(:with)
        allow(request_stub).to receive(:to_return)
        allow(request_stub).to receive(:to_raise)
        allow(request_stub).to receive(:to_timeout)

        build
      end

      context "when given a request query" do
        let(:request_query) { { abd: :def } }

        it "configures webmock with query" do
          expect(request_stub).to have_received(:with).with(a_hash_including(query: request_query))
        end
      end

      context "when given a request headers" do
        let(:request_headers) { { "Accept" => "N/A" } }

        it "configures webmock with request_headers" do
          expect(request_stub).to have_received(:with).with(a_hash_including(headers: request_headers))
        end
      end

      context "when given a request body" do
        let(:request_body) { { rock: "'n'roll" } }

        it "configures webmock with request_body" do
          expect(request_stub).to have_received(:with).with(a_hash_including(body: request_body))
        end
      end

      context "when given a response status" do
        let(:response_status) { 500 }

        it "configures webmock with response_status" do
          expect(request_stub).to have_received(:to_return).with(a_hash_including(status: response_status))
        end
      end

      context "when given a response headers" do
        let(:response_headers) { { "Accept" => "application/crashes" } }

        it "configures webmock with response_headers" do
          expect(request_stub).to have_received(:to_return).with(a_hash_including(headers: response_headers))
        end
      end

      context "when given a response body" do
        let(:response_body) { { float: :my_boat } }

        it "configures webmock with response_body" do
          expect(request_stub).to have_received(:to_return).with(a_hash_including(body: response_body))
        end
      end

      context "when given an error" do
        let(:error) { StandardError }

        it "configures webmock to_raise" do
          expect(request_stub).to have_received(:to_raise).with(error)
        end
      end
    end
  end
end

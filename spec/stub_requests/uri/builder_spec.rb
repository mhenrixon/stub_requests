# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::URI::Builder do
  let(:builder)      { described_class.new(uri, route_params) }
  let(:uri)          { StubRequests::URI.safe_join(service_uri, path) }
  let(:service_uri)  { "http://service-name:9292/internal" }
  let(:path)         { "another/:bogus/endpoint" }
  let(:route_params) { { bogus: :random } }

  describe "#build" do
    subject(:build) { builder.build }

    it { is_expected.to eq("http://service-name:9292/internal/another/random/endpoint") }

    context "when endpoint has unused uri segments" do
      let(:route_params) { { rocks: :my_world, my_boat: :floats } }
      let(:error_message) do
        "The URI (http://service-name:9292/internal/another/:bogus/endpoint) expected the following route params `:bogus` but received `:rocks, :my_boat`"
      end

      specify { expect { build }.to raise_error(StubRequests::UriSegmentMismatch, error_message) }
    end

    context "when endpoint has not replaced URI segments" do
      let(:path) { "another/:bogus/endpoint/:without_any/value" }
      let(:error_message) do
        "The URI (http://service-name:9292/internal/another/:bogus/endpoint/:without_any/value)" \
        " expected the following route params `:bogus, :without_any` but received `:bogus`"
      end

      specify { expect { build }.to raise_error(StubRequests::UriSegmentMismatch, error_message) }
    end

    context "when constructed URI is invalid" do
      let(:path) { "another/:bogus/end point\ /thjat doesn't work" }

      before do
        allow(StubRequests.logger).to receive(:warn)
        build
      end

      it "logs a helpful warning message" do
        expect(StubRequests.logger).to have_received(:warn).with(
          "URI (http://service-name:9292/internal/another/random/end point /thjat doesn't work) is not valid.",
        )
      end

      it { is_expected.to eq("http://service-name:9292/internal/another/random/end point /thjat doesn't work") }
    end
  end
end

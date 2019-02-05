# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::URI::Builder do
  let(:builder) { described_class.new(service_uri, path, route_params) }

  let(:service_uri) { "http://service-name:9292/internal" }
  let(:path)         { "another/:bogus/endpoint" }
  let(:route_params) { { bogus: :random } }

  describe "#build" do
    subject(:build) { builder.build }

    it { is_expected.to eq("http://service-name:9292/internal/another/random/endpoint") }

    context "when endpoint has unused route params" do
      let(:route_params) { { rocks: :my_world, my_boat: :floats } }
      let(:error_class)  { StubRequests::UriSegmentMismatch }
      let(:error_message) do
        "The route param(s) [:rocks,:my_boat] are missing in template (another/:bogus/endpoint)"
      end

      it! { is_expected.to raise_error(error_class, error_message) }
    end

    context "when endpoint has not replaced URI segments" do
      let(:path) { "another/:bogus/endpoint/:without_any/value" }
      let(:error_class) { StubRequests::UriSegmentMismatch }
      let(:error_message) do
        "The route param(s) [:without_any] were not replaced in" \
        " template (another/random/endpoint/:without_any/value)." \
        " Given route_params=[:bogus]"
      end

      it! { is_expected.to raise_error(error_class, error_message) }
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

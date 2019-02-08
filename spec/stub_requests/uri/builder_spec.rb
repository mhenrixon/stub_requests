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

      specify do
        expect { build }.to raise_error do |error|
          expect(error).to be_a(StubRequests::UriSegmentMismatch)
          expect(error.message).to include(
            "The URI (http://service-name:9292/internal/another/:bogus/endpoint)" \
            " received unexpected route parameters"
          )

          expect(error.message).to include("Expected: [:bogus]")
          expect(error.message).to include("Received: [:rocks,:my_boat]")
          expect(error.message).to include("Missing: [:bogus]")
          expect(error.message).to include("Invalid: [:rocks,:my_boat]")
        end
      end
    end

    context "when endpoint has not replaced URI segments" do
      let(:path) { "another/:bogus/endpoint/:without_any/value" }

      specify do
        expect { build }.to raise_error do |error|
          expect(error).to be_a(StubRequests::UriSegmentMismatch)
          expect(error.message).to include(
            "The URI (http://service-name:9292/internal/another/:bogus/endpoint/:without_any/value)" \
            " received unexpected route parameters"
          )

          expect(error.message).to include("Expected: [:bogus,:without_any]")
          expect(error.message).to include("Received: [:bogus]")
          expect(error.message).to include("Missing: [:without_any]")
          expect(error.message).not_to include("Invalid: ")
        end
      end
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

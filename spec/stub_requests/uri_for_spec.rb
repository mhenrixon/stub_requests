# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::UriFor do
  describe "#uri_for" do
    subject(:uri_for) { described_class.uri_for(service_uri, uri_template, uri_replacements) }

    let(:service_uri)  { "http://service-name:9292/internal" }
    let(:uri_template) { "another/:bogus/endpoint" }
    let(:uri_replacements) { { bogus: :random } }

    it { is_expected.to eq("http://service-name:9292/internal/another/random/endpoint") }

    context "when endpoint has unused uri segments" do
      let(:uri_replacements) { { rocks: :my_world, my_boat: :floats } }

      specify do
        expect { uri_for }.to raise_error(
          StubRequests::UriSegmentMismatch,
          "The uri segment(s) [:rocks,:my_boat] are missing in uri_template (another/:bogus/endpoint)",
        )
      end
    end

    context "when endpoint has unreplaced uri segments" do
      let(:uri_template) { "another/:bogus/endpoint/:without_any/value" }

      specify do
        expect { uri_for }.to raise_error(
          StubRequests::UriSegmentMismatch,
          "The uri segment(s) [:without_any] were not replaced" \
          " in uri_template (another/random/endpoint/:without_any/value)." \
          " Given uri_replacements=[bogus]",
        )
      end
    end

    context "when constructed uri is invalid" do
      let(:uri_template) { "another/:bogus/end point\ /thjat doesn't work" }

      it "logs a helpful warning message" do
        expect(StubRequests.logger).to receive(:warn).with(
          "Uri (http://service-name:9292/internal/another/random/end point /thjat doesn't work) is not valid.",
        )
        expect(uri_for).to eq("http://service-name:9292/internal/another/random/end point /thjat doesn't work")
      end
    end
  end
end

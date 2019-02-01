# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::URI::Suffix do
  describe ".valid?" do
    subject { described_class.valid?(host) }

    let(:host) { uri.host }
    let(:uri)  { URI.parse(url) }

    context "when given a URI with suffix" do
      let(:url) { "http://example.com:9393/internal/v1/users/123" }

      it { is_expected.to eq(true) }
    end

    context "when given a URI without suffix" do
      let(:url) { "http://example-com:9393/internal/v1/users/123" }

      it { is_expected.to eq(false) }
    end
  end
end

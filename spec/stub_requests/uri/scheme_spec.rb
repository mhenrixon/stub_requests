# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::URI::Scheme do
  describe ".valid?" do
    subject { described_class.valid?(scheme) }

    context "when given nil" do
      let(:scheme) { nil }

      it { is_expected.to eq(false) }
    end

    context "when given 'http'" do
      let(:scheme) { "http" }

      it { is_expected.to eq(true) }
    end

    context "when given 'https'" do
      let(:scheme) { "https" }

      it { is_expected.to eq(true) }
    end
  end
end

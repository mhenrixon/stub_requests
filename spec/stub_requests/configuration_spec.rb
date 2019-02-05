# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Configuration do
  let(:config) { described_class.new }

  describe "#record_metrics" do
    subject(:record_metrics) { config.record_metrics }

    context "when not configured" do
      it { is_expected.to eq(false) }
    end

    context "when configured with true" do
      before { config.record_metrics = true }

      it { is_expected.to eq(true) }
    end
  end

  describe "#record_metrics=" do
    subject { config.record_metrics = new_value }

    let(:new_value) { true }

    context "when new value is valid" do
      it { is_expected.to eq(true) }
    end

    context "when new value is invalid" do
      let(:new_value) { "I can't type" }

      let(:error) { StubRequests::InvalidArgumentType }
      let(:message) do
        "Got `I can't type` for argument `:record_metrics`. Expected it to be a `(TrueClass, FalseClass)`"
      end

      it! { is_expected.to raise_error(error, message) }
    end
  end

  describe "#record_metrics?" do
    subject { config.record_metrics? }

    it { is_expected.to eq(false) }

    context "when record_metrics is true" do
      before { config.record_metrics = true }

      it { is_expected.to eq(true) }
    end
  end
end

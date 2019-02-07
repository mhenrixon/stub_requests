# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Configuration do
  let(:config) { described_class.new }

  describe "#record_stubs" do
    subject(:record_stubs) { config.record_stubs }

    context "when not configured" do
      it { is_expected.to eq(false) }
    end

    context "when configured with true" do
      before { config.record_stubs = true }

      it { is_expected.to eq(true) }
    end
  end

  describe "#record_stubs=" do
    subject { config.record_stubs = new_value }

    let(:new_value) { true }

    context "when new value is valid" do
      it { is_expected.to eq(true) }
    end

    context "when new value is invalid" do
      let(:new_value) { "I can't type" }

      let(:error) { StubRequests::InvalidArgumentType }
      let(:message) do
        "The argument `:record_stubs` was `String`, expected any of [TrueClass, FalseClass]"
      end

      it! { is_expected.to raise_error(error, message) }
    end
  end

  describe "#record_stubs?" do
    subject { config.record_stubs? }

    it { is_expected.to eq(false) }

    context "when record_stubs is true" do
      before { config.record_stubs = true }

      it { is_expected.to eq(true) }
    end
  end
end

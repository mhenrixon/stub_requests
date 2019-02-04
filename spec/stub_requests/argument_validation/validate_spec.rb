# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::ArgumentValidation, ".validate!" do
  subject(:validate) { described_class.validate!(name, value, type: type) }

  let(:argument) { { name: name, value: obj, type: type } }
  let(:name)  { :an_argument }
  let(:value) { "bogus" }
  let(:type)  { String }

  context "when given nil for :name" do
    let(:name) { nil }

    let(:error_class) { StubRequests::InvalidArgumentType }
    let(:error_message) do
      "The argument `:name` was `NilClass`, expected any of [Symbol, String]"
    end

    it! { is_expected.to raise_error(error_class, error_message) }
  end

  context "when given a string value" do
    context "when only String is allowed" do
      it { is_expected.to be(true) }
    end

    context "and an array including String is allowed" do
      let(:type) { [String, NilClass] }

      it { is_expected.to be(true) }
    end

    context "and an array excluding String is allowed" do
      let(:type) { [TrueClass, FalseClass, NilClass] }

      let(:error)   { StubRequests::InvalidArgumentType }
      let(:message) { "The argument `:an_argument` was `String`, expected any of [TrueClass, FalseClass, NilClass]" }

      it! { is_expected.to raise_error(error, message) }
    end
  end
end

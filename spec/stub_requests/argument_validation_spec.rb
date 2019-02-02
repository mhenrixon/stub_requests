# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::ArgumentValidation do
  describe ".validate!" do
    subject(:validate) { described_class.validate!(value, is_a: is_a) }

    let(:value) { "bogus" }
    let(:is_a)  { String }

    context "when given a string value" do
      context "when only String is allowed" do
        it { is_expected.to be(true) }
      end

      context "when an array including String is allowed" do
        let(:is_a) { [String, NilClass] }

        it { is_expected.to be(true) }
      end

      context "when an array excluding String is allowed" do
        let(:is_a) { [TrueClass, FalseClass, NilClass] }

        let(:error)   { StubRequests::InvalidType }
        let(:message) { "Expected `String` to be any of [TrueClass, FalseClass, NilClass]" }

        it! { is_expected.to raise_error(error, message) }
      end
    end
  end
end

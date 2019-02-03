# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Property::Validator do
  let(:validator)  { described_class.new(name, type, default, properties) }
  let(:name)       { :a_method_name }
  let(:type)       { String }
  let(:default)    { "A default value" }
  let(:properties) { {} }

  describe ".call" do
    subject(:call) { described_class.call(name, type, default, properties) }

    it "delegates to #run_validations" do
      allow(described_class).to receive(:new).and_return(validator)
      allow(validator).to receive(:run_validations)

      call
      expect(validator).to have_received(:run_validations)
    end
  end

  describe "#initialize" do
    subject { validator }

    its(:name)       { is_expected.to eq(name) }
    its(:type)       { is_expected.to eq([type]) }
    its(:default)    { is_expected.to eq(default) }
    its(:properties) { is_expected.to eq(properties) }
  end

  describe "#run_validations" do
    subject(:run_validations) { validator.run_validations }

    context "when name is not a Symbol" do
      let(:name)    { nil }
      let(:error)   { StubRequests::InvalidArgumentType }
      let(:message) { "The argument `:name` was `NilClass`, expected any of [Symbol]" }

      it! { is_expected.to raise_error(error, message) }
    end

    context "when default is not a type" do
      let(:default) { true }
      let(:error)   { StubRequests::InvalidArgumentType }
      let(:message) do
        "The argument `:default` was `TrueClass`, expected any of [String]"
      end

      it! { is_expected.to raise_error(error, message) }
    end

    context "when already defined" do
      let(:properties) { { name => { type: [TrueClass, FalseClass] } } }
      let(:error)      { StubRequests::PropertyDefined }
      let(:message) do
        "Property #a_method_name was already defined as `{ type: [TrueClass, FalseClass], default: nil }"
      end

      it! { is_expected.to raise_error(error, message) }
    end
  end
end

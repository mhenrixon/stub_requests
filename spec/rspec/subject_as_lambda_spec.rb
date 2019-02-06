# frozen_string_literal: true

require "spec_helper"

RSpec.describe RSpec::SubjectAsLambda do
  class NullFormatter
    private

    def method_missing(method, *args, &block) # rubocop:disable Style/MethodMissingSuper, Style/MissingRespondToMissing
      # ignore
    end
  end

  let(:stub)    { double }
  let(:error)   { ArgumentError }
  let(:message) { "nice message" }

  describe "#it!" do
    before { allow(stub).to receive(:message).and_raise(error, message) }

    context "with explicit subject" do
      subject { stub.message }

      context "with some metadata" do
        it! { is_expected.to raise_error(error, message) }
      end

      describe "in shared_context" do
        shared_context "when sharing stuff" do
          subject { stub.message }

          it! { is_expected.to raise_error(error, message) }
        end

        include_context "when sharing stuff"
      end
    end

    context "with metadata" do
      context "preserves access to metadata that doesn't end in hash" do # rubocop:disable RSpec/ContextWording
        it!(:foo) do |example|
          expect(example.metadata[:foo]).to be(true)
        end
      end

      context "preserves access to metadata that ends in hash" do # rubocop:disable RSpec/ContextWording
        it!(:foo, bar: 17) do |example|
          expect(example.metadata[:foo]).to be(true)
          expect(example.metadata[:bar]).to be(17)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::URI::Validator do
  let(:validator) { described_class.new(uri) }
  let(:uri)       { "http://example.org/api/v8/boguses" }

  describe "#valid?" do
    subject(:valid) { validator.valid? }

    it { is_expected.to eq(true) }

    context "when given an invalid URI" do
      let(:uri) { "a random bogus string" }

      specify do
        expect { valid }.to raise_error(StubRequests::InvalidUri, "'a random bogus string' is not a valid URI.")
      end
    end
  end
end

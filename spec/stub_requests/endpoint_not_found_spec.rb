# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::EndpointNotFound do
  subject { described_class.new(id: endpoint_id, suggestions: suggestions) }

  let(:endpoint_id) { :documents_show }
  let(:suggestions) { nil }

  let(:expected_message) do
    a_string_starting_with(
      "Couldn't find an endpoint with id=:#{endpoint_id}",
    )
  end

  context "when given an array of suggestions" do
    let(:suggestions) do
      [
        :bogus,
        :value,
      ]
    end
    let(:expected_suggestions) do
      a_string_ending_with(
        "Did you mean one of the following? (:bogus, :value)",
      )
    end

    its(:message) { is_expected.to match(expected_message) }
    its(:message) { is_expected.to match(expected_suggestions) }
  end
end

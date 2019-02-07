# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Utils::Fuzzy do
  describe ".match" do
    subject(:match) { described_class.match(string, strings) }

    let(:string)  { :person_identification_show }

    context "when size is smaller than or equal to 3" do
      let(:strings) do
        [
          :identifications_index,
          :signings_show,
          :person_identifications_index,
        ]
      end
      let(:expected_matches) do
        [
          :person_identifications_index,
          :identifications_index,
          :signings_show,
        ]
      end

      it { is_expected.to eq(expected_matches) }
    end

    context "when size is greater than 3" do
      let(:strings) do
        [
          :identifications_index,
          :person_identification_show,
          :identification_show,
          :first_successful_person_identification,
          :last_legitimation_data,
          :signings_show,
          :person_identifications_index,
        ]
      end

      let(:expected_matches) do
        [
          :person_identification_show,
          :person_identifications_index,
          :identification_show,
          :identifications_index,
        ]
      end

      it { is_expected.to eq(expected_matches) }
    end
  end
end

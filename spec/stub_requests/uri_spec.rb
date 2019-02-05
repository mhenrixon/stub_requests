# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::URI do
  describe ".safe_join" do
    subject(:safe_join) { described_class.safe_join(host, path) }

    let(:host) { "https://domain.com/api/v1/" }
    let(:path) { "/users/:id/boogers" }

    it { is_expected.to eq("https://domain.com/api/v1/users/:id/boogers") }
  end

  describe ".route_params" do
    subject(:route_params) { described_class.route_params(uri) }

    # TODO: Support route parameters with `{task_id}`
    xcontext "when defining keys with {}" do
      let(:uri) { "persons/{person_id}/integrations/{id}" }

      it { is_expected.to eq([:person_id, :id]) }
    end

    context "when defining keys with :" do
      let(:uri) { "persons/:bogus_id/integrations/:horrible" }

      it { is_expected.to eq([:bogus_id, :horrible]) }
    end

    context "with a weird invalid URI" do
      let(:uri) { "persons/%^*&%R*^/integrations/:yippie" }

      it { is_expected.to eq([:yippie]) }
    end
  end
end

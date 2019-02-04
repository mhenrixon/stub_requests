# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests do
  describe ".register_service" do
    subject(:register_service) do
      described_class.register_service(service_id, service_uri)
    end

    let(:service_id)  { :person_identification }
    let(:service_uri) { "http://example.org/api/v1/internal" }

    it "updates service_registry with the new service" do
      expect { register_service }
        .to change { StubRequests::Registration::Registry.instance.services.size }
        .by(1)
    end
  end

  describe ".configure" do
    it "yields config" do
      described_class.configure do |config|
        expect(config).to be_a(StubRequests::Configuration)
      end
    end
  end
end

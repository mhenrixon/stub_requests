# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::ServiceRegistry do
  let(:registry)    { described_class.instance }
  let(:service)     { StubRequests::Service.new(service_id, service_uri) }
  let(:service_id)  { :basecamp }
  let(:service_uri) { "http://basecamp.com/v3" }

  describe "#register_service" do
    subject(:register_service) { registry.register_service(service) }

    it { is_expected.to be_a(StubRequests::Service) }

    its(:id) { is_expected.to eq(service_id) }
    its(:uri) { is_expected.to eq(service_uri) }

    context "when service is registered" do
      let(:other) { StubRequests::Service.new(service_id, service_uri) }

      before do
        allow(StubRequests.logger).to receive(:warn)
        registry.register_service(other)
      end

      context "without registered endpoints" do
        it "logs a helpful error message" do
          register_service

          expect(StubRequests.logger).to have_received(:warn)
            .with("Service already registered #{service}")
        end
      end

      context "with registered endpoints" do
        before { other.register_endpoint(:bogus, :delete, "bogus/:id") }

        specify do
          expect { register_service }.to raise_error(
            StubRequests::ServiceHaveEndpoints, "Service with id basecamp have already been registered. #{other}"
          )
        end
      end
    end
  end

  describe "#reset!" do
    subject(:reset) { registry.reset! }

    context "when no services are registered" do
      specify do
        expect { reset }.not_to change { registry.services.size }.from(0)
      end
    end

    context "when services are registered" do
      before { registry.register_service(service) }

      specify do
        expect { reset }.to change { registry.services.size }.from(1).to(0)
      end
    end
  end

  describe "#remove_service" do
    subject(:remove_service) { registry.remove_service(service_id) }

    context "when service is unregistered" do
      specify do
        expect { remove_service }.to raise_error(
          StubRequests::ServiceNotFound,
          "Couldn't find a service with id=:basecamp",
        )
      end
    end

    context "when service is registered" do
      before { registry.register_service(service) }

      specify do
        expect { remove_service }.to change { registry.services.size }.from(1).to(0)
      end
    end
  end

  describe "#get_service" do
    subject(:get_service) { registry.get_service(service_id) }

    context "when service is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when service is registered" do
      before { registry.register_service(service) }

      it { is_expected.to eq(service) }
    end
  end

  describe "#get_service!" do
    subject(:get_service) { registry.get_service!(service_id) }

    context "when service is unregistered" do
      specify do
        expect { get_service }.to raise_error(
          StubRequests::ServiceNotFound,
          "Couldn't find a service with id=:basecamp",
        )
      end
    end

    context "when service is registered" do
      before { registry.register_service(service) }

      it { is_expected.to eq(service) }
    end
  end
end

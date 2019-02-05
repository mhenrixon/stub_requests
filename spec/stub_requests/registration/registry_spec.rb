# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::ServiceRegistry do
  let(:registry)    { described_class.instance }
  let(:service)     { StubRequests::Service.new(service_id, service_uri) }
  let(:service_id)  { :basecamp }
  let(:service_uri) { "http://basecamp.com/v3" }

  describe "#register" do
    subject(:register) { registry.register(service_id, service_uri) }

    it { is_expected.to be_a(StubRequests::Service) }

    its(:id) { is_expected.to eq(service_id) }
    its(:uri) { is_expected.to eq(service_uri) }

    context "when service is registered" do
      let(:other_service)     { registry.register(other_service_id, other_service_uri) }
      let(:other_service_id)  { service_id }
      let(:other_service_uri) { service_uri }

      before do
        allow(StubRequests.logger).to receive(:warn)
        other_service
      end

      context "without registered endpoints" do
        it "logs a helpful error message" do
          register

          expect(StubRequests.logger).to have_received(:warn)
            .with("Service already registered #{service}")
        end
      end

      context "with registered endpoints" do
        before { other_service.register(:bogus, :delete, "bogus/:id") }

        let(:error_message) do
          "Service with id basecamp have already been registered. #{other_service}"
        end

        specify { expect { register }.to raise_error(StubRequests::ServiceHaveEndpoints, error_message) }
      end
    end
  end

  describe "#reset" do
    subject(:reset) { registry.reset }

    context "when no services are registered" do
      it! { is_expected.not_to change { registry.services.size }.from(0) }
    end

    context "when services are registered" do
      before { registry.register(service_id, service_uri) }

      it! { is_expected.to change { registry.services.size }.from(1).to(0) }
    end
  end

  describe "#remove" do
    subject(:remove) { registry.remove(service_id) }

    context "when service is unregistered" do
      let(:error)   { StubRequests::ServiceNotFound }
      let(:message) { "Couldn't find a service with id=:basecamp" }

      it! { is_expected.to raise_error(error, message) }
    end

    context "when service is registered" do
      before { registry.register(service_id, service_uri) }

      it! { is_expected.to change { registry.services.size }.from(1).to(0) }
    end
  end

  describe "#find" do
    subject(:find) { registry.find(service_id) }

    context "when service is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when service is registered" do
      before { registry.register(service_id, service_uri) }

      it { is_expected.to eq(service) }
    end
  end

  describe "#find!" do
    subject(:find) { registry.find!(service_id) }

    context "when service is unregistered" do
      let(:error)   { StubRequests::ServiceNotFound }
      let(:message) { "Couldn't find a service with id=:basecamp" }

      it! { is_expected.to raise_error(error, message) }
    end

    context "when service is registered" do
      before { registry.register(service_id, service_uri) }

      it { is_expected.to eq(service) }
    end
  end
end

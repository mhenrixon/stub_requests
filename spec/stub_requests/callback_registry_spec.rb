# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::CallbackRegistry do
  let(:registry)    { described_class.instance }
  let(:service_id)  { :documents }
  let(:endpoint_id) { :show }
  let(:verb)        { :any }
  let(:callback)    { -> {} }

  describe "#register" do
    subject(:register) { registry.register(service_id, endpoint_id, verb, callback) }

    context "without existing callbacks" do
      it! { is_expected.to change(registry.callbacks, :size).by(1) }

      it { is_expected.to be_a(StubRequests::Callback) }
      its(:service_id)  { is_expected.to eq(service_id) }
      its(:endpoint_id) { is_expected.to eq(endpoint_id) }
      its(:verb)        { is_expected.to eq(verb) }
      its(:callback)    { is_expected.to be_a(Proc) }
    end

    context "with existing callbacks" do
      before do
        registry.register(service_id, endpoint_id, verb, callback)
      end

      it! { is_expected.not_to change(registry.callbacks, :size) }

      it { is_expected.to be_a(StubRequests::Callback) }
      its(:service_id)  { is_expected.to eq(service_id) }
      its(:endpoint_id) { is_expected.to eq(endpoint_id) }
      its(:verb)        { is_expected.to eq(verb) }
      its(:callback)    { is_expected.to be_a(Proc) }
    end

    context "with existing difference callbacks" do
      before do
        registry.register(:another, :endpoint, :any, callback)
      end

      it! { is_expected.to change(registry.callbacks, :size) }

      it { is_expected.to be_a(StubRequests::Callback) }
      its(:service_id)  { is_expected.to eq(service_id) }
      its(:endpoint_id) { is_expected.to eq(endpoint_id) }
      its(:verb)        { is_expected.to eq(verb) }
      its(:callback)    { is_expected.to be_a(Proc) }
    end
  end

  describe "#unregister" do
    subject(:unregister) { registry.unregister(service_id, endpoint_id, verb) }

    context "without existing callbacks" do
      it! { is_expected.not_to change(registry.callbacks, :size) }

      it { is_expected.to eq(nil) }
    end

    context "with existing callbacks" do
      before do
        registry.register(service_id, endpoint_id, verb, callback)
      end

      it! { is_expected.to change(registry.callbacks, :size).by(-1) }

      its(:callback) { is_expected.to eq(callback) }
    end
  end

  describe "#invoke_callbacks" do
    subject(:invoke_callbacks) { registry.invoke_callbacks(request) }

    let(:request) do
      instance_spy(
        StubRequests::RequestStub,
        service_id: service_id,
        endpoint_id: endpoint_id,
        verb: verb,
      )
    end

    context "without existing callbacks" do
      before { allow(callback).to receive(:call) }

      it "does not call back" do
        invoke_callbacks
        expect(callback).not_to have_received(:call)
      end
    end

    context "with existing callbacks" do
      before do
        registry.register(service_id, endpoint_id, verb, callback)
        allow(callback).to receive(:call)
      end

      context "when callback has 0 argument(s)" do
        it "calls back" do
          invoke_callbacks
          expect(callback).to have_received(:call)
        end
      end

      context "when callback has 1 argument(s)" do
        let(:callback) { ->(_request) { "N/A" } }

        it "calls back" do
          invoke_callbacks
          expect(callback).to have_received(:call).with(request)
        end
      end

      context "when callback has 2 argument(s)" do
        let(:callback)    { ->(_one, _two) { "N/A" } }
        let(:error_class) { StubRequests::InvalidCallback }
        let(:error_message) do
          "The callback for a callback can either take 0 or 1 arguments (was 2)"
        end

        it! { is_expected.to raise_error(error_class, error_message) }
      end
    end
  end
end

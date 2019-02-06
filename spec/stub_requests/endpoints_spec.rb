# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Endpoints do
  let(:endpoints)    { described_class.new(service) }
  let(:service)      { instance_spy(StubRequests::Service) }
  let(:endpoint)     { StubRequests::Endpoint.new(service, endpoint_id, verb, path) }
  let(:endpoint_id)  { :resource_collection }
  let(:verb)         { :find }
  let(:path)         { "resource/:resource_id/collection" }

  describe "#initialize" do
    subject { endpoints }

    its(:endpoints) { is_expected.to be_a(Concurrent::Map) }
  end

  describe "#register" do
    subject(:register) { endpoints.register(endpoint_id, verb, path) }

    it "registers the endpoint in the collection" do
      expect { register }.to change { endpoints.endpoints.size }.by(1)
    end

    it { is_expected.to eq(endpoint) }
  end

  describe "#each" do
    subject(:each) { endpoints.each }

    context "when given no block" do
      it { is_expected.to be_a(::Enumerator) }
    end

    context "when given a block" do
      context "when endpoint is unregistered" do
        specify do
          value = nil
          each { |endpoint| value = endpoint.id }
          expect(value).to eq(nil)
        end
      end

      context "when endpoint is registered" do
        before { endpoints.register(endpoint_id, verb, path) }

        specify do
          each { |ep| expect(ep.id).to eq(endpoint.id) }
        end
      end

      it "delegates to @endpoints" do
        block = ->(endpoint) { endpoint }
        allow(endpoints.endpoints).to receive(:each).and_call_original
        each(&block)
        expect(endpoints.endpoints).to have_received(:each).with(no_args, &block)
      end
    end
  end

  describe "#find" do
    subject(:find) { endpoints.find(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint_id, verb, path) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#find!" do
    subject(:find) { endpoints.find!(endpoint_id) }

    let(:error)   { StubRequests::EndpointNotFound }
    let(:message) { "Couldn't find an endpoint with id=:resource_collection" }

    context "when endpoint is unregistered" do
      it! { is_expected.to raise_error(error, message) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint_id, verb, path) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#update" do
    subject(:update) { endpoints.update(endpoint_id, new_verb, new_path) }

    let(:new_verb) { :post }
    let(:new_path) { "resource/:resource_id" }

    let(:error)   { StubRequests::EndpointNotFound }
    let(:message) { "Couldn't find an endpoint with id=:resource_collection" }

    context "when endpoint is unregistered" do
      it! { is_expected.to raise_error(error, message) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint_id, verb, path) }

      its(:id)           { is_expected.to eq(endpoint_id) }
      its(:verb)         { is_expected.to eq(new_verb) }
      its(:path) { is_expected.to eq(new_path) }
    end
  end

  describe "#remove" do
    subject(:remove) { endpoints.remove(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint_id, verb, path) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#to_s" do
    subject(:to_s) { endpoints.to_s }

    context "when no endpoints are registered" do
      it { is_expected.to eq("#<StubRequests::Endpoints endpoints=[]>") }
    end

    context "when endpoints are registered" do
      before do
        endpoints.register(:bogus_id, :any, "documents/:document_id")
      end

      let(:expected_output) do
        "#<StubRequests::Endpoints endpoints=["\
          "#<StubRequests::Endpoint id=:bogus_id verb=:any path='documents/:document_id'>"\
        "]>"
      end

      it { is_expected.to eq(expected_output) }
    end
  end
end

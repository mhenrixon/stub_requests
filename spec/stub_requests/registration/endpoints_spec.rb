# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Registration::Endpoints do
  let(:registry)     { described_class.new }
  let(:endpoint)     { StubRequests::Registration::Endpoint.new(endpoint_id, verb, uri_template) }
  let(:endpoint_id)  { :resource_collection }
  let(:verb)         { :find }
  let(:uri_template) { "resource/:resource_id/collection" }

  describe "#initialize" do
    its(:endpoints) { is_expected.to be_a(Concurrent::Map) }
  end

  describe "#register" do
    subject(:register) { registry.register(endpoint_id, verb, uri_template) }

    it "registers the endpoint in the collection" do
      expect { register }.to change { registry.endpoints.size }.by(1)
    end

    it { is_expected.to eq(endpoint) }
  end

  describe "#each" do
    subject(:each) { registry.each }

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
        before { registry.register(endpoint_id, verb, uri_template) }

        specify do
          each { |ep| expect(ep.id).to eq(endpoint.id) }
        end
      end

      it "delegates to @endpoints" do
        block = ->(endpoint) { endpoint }
        allow(registry.endpoints).to receive(:each).and_call_original
        each(&block)
        expect(registry.endpoints).to have_received(:each).with(no_args, &block)
      end
    end
  end

  describe "#find" do
    subject(:find) { registry.find(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { registry.register(endpoint_id, verb, uri_template) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#find!" do
    subject(:find) { registry.find!(endpoint_id) }

    let(:error)   { StubRequests::EndpointNotFound }
    let(:message) { "Couldn't find an endpoint with id=:resource_collection" }

    context "when endpoint is unregistered" do
      it! { is_expected.to raise_error(error, message) }
    end

    context "when endpoint is registered" do
      before { registry.register(endpoint_id, verb, uri_template) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#update" do
    subject(:update) { registry.update(endpoint_id, new_verb, new_uri_template, new_default_options) }

    let(:new_verb)            { :post }
    let(:new_uri_template)    { "resource/:resource_id" }
    let(:new_default_options) { { response: { body: "" } } }

    let(:error)   { StubRequests::EndpointNotFound }
    let(:message) { "Couldn't find an endpoint with id=:resource_collection" }

    context "when endpoint is unregistered" do
      it! { is_expected.to raise_error(error, message) }
    end

    context "when endpoint is registered" do
      before { registry.register(endpoint_id, verb, uri_template) }

      its(:id)           { is_expected.to eq(endpoint_id) }
      its(:verb)         { is_expected.to eq(new_verb) }
      its(:uri_template) { is_expected.to eq(new_uri_template) }
      its(:options)      { is_expected.to eq(new_default_options) }
    end
  end

  describe "#remove" do
    subject(:remove) { registry.remove(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { registry.register(endpoint_id, verb, uri_template) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#to_s" do
    subject(:to_s) { registry.to_s }

    context "when no endpoints are registered" do
      it { is_expected.to eq("#<StubRequests::Registration::Endpoints endpoints=[]>") }
    end

    context "when endpoints are registered" do
      before do
        registry.register(:bogus_id, :any, "documents/:document_id")
      end

      let(:expected_output) do
        "#<StubRequests::Registration::Endpoints endpoints=["\
          "#<StubRequests::Registration::Endpoint id=:bogus_id verb=:any uri_template='documents/:document_id'>"\
        "]>"
      end

      it { is_expected.to eq(expected_output) }
    end
  end
end

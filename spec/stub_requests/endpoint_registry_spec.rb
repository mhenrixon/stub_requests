# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::EndpointRegistry do
  let(:registry)    { described_class.instance }
  let(:service)     { instance_spy(StubRequests::Service) }
  let(:endpoint)    { StubRequests::Endpoint.new(endpoint_attributes) }
  let(:service_id)  { :list_service }
  let(:service_uri) { "https://api.app.com/v5" }
  let(:endpoint_id) { :list_todos_index }
  let(:verb)        { :get }
  let(:path)        { "list/:list_id/todos" }

  let(:endpoint_attributes) do
    {
      endpoint_id: endpoint_id,
      service_id: service_id,
      service_uri: service_uri,
      verb: verb,
      path: path,
    }
  end

  describe "#initialize" do
    subject { registry }

    its(:endpoints) { is_expected.to be_a(Concurrent::Map) }
  end

  describe "#register" do
    subject(:register) { registry.register(endpoint) }

    let(:endpoint_id)     { :concrete }
    let(:verb)            { :get }
    let(:path)            { "concretes/:concrete_id" }

    context "when endpoint is unregistered" do
      it { is_expected.to be_a(StubRequests::Endpoint) }

      its(:id)   { is_expected.to eq(endpoint_id) }
      its(:verb) { is_expected.to eq(verb) }
      its(:path) { is_expected.to eq(path) }
    end

    context "when endpoint is registered" do
      before { registry.register(old_endpoint) }

      let(:old_endpoint) { StubRequests::Endpoint.new(old_attributes) }
      let(:old_verb)     { :post }
      let(:old_path)     { "concrete" }
      let(:old_attributes) do
        endpoint_attributes.merge(verb: old_verb, path: old_path)
      end

      its(:id)   { is_expected.to eq(endpoint_id) }
      its(:verb) { is_expected.to eq(verb) }
      its(:path) { is_expected.to eq(path) }
    end
  end

  describe "#register" do
    subject(:register) { registry.register(endpoint) }

    it "registers the endpoint in the collection" do
      expect { register }.to change(registry, :size).by(1)
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
        before { registry.register(endpoint) }

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

  describe "#find!" do
    subject(:find) { registry.find!(endpoint_id) }

    let(:error)   { StubRequests::EndpointNotFound }
    let(:message) { "Couldn't find an endpoint with id=:#{endpoint.id}." }

    context "when endpoint is unregistered" do
      it! { is_expected.to raise_error(error, message) }
    end

    context "when endpoint is registered" do
      before { registry.register(endpoint) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#delete" do
    subject(:delete) { registry.delete(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { registry.register(endpoint) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#to_s" do
    subject(:to_s) { registry.to_s }

    context "when no endpoints are registered" do
      it { is_expected.to eq("#<StubRequests::EndpointRegistry endpoints=[]>") }
    end

    context "when endpoints are registered" do
      before do
        registry.register(endpoint)
      end

      let(:expected_output) do
        "#<StubRequests::EndpointRegistry endpoints=["\
          "#<StubRequests::Endpoint id=:list_todos_index verb=:get path='list/:list_id/todos'>"\
        "]>"
      end

      it { is_expected.to eq(expected_output) }
    end
  end
end

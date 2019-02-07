# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Service do
  let(:service)            { described_class.new(service_id, service_uri) }
  let(:service_id)         { :abstractions }
  let(:service_uri)        { "https://abstractions.com/v1" }
  let(:endpoint_id)        { :concrete }
  let(:verb)               { :get }
  let(:path)               { "concretes/:concrete_id" }
  let(:default_options)    { {} }
  let(:service_registry)   { StubRequests::ServiceRegistry.instance }
  let(:endpoint_registry)  { StubRequests::EndpointRegistry.instance }

  describe "#initialize" do
    subject { service }

    its(:id) { is_expected.to eq(service_id) }
    its(:uri) { is_expected.to eq(service_uri) }
  end

  shared_examples "convenient endpoint registration" do
    subject(:register) { service.send(verb, path, as: endpoint_id) }

    before do
      allow(service).to receive(:register).and_return(true)
      register
    end

    it "delegates to #register" do
      expect(service).to have_received(:register)
        .with(endpoint_id, verb, path)
    end
  end

  describe "#any" do
    let(:verb) { :any }

    it_behaves_like "convenient endpoint registration"
  end

  describe "#get" do
    let(:verb) { :get }

    it_behaves_like "convenient endpoint registration"
  end

  describe "#post" do
    let(:verb) { :post }

    it_behaves_like "convenient endpoint registration"
  end

  describe "#patch" do
    let(:verb) { :patch }

    it_behaves_like "convenient endpoint registration"
  end

  describe "#put" do
    let(:verb) { :put }

    it_behaves_like "convenient endpoint registration"
  end

  describe "#delete" do
    let(:verb) { :delete }

    it_behaves_like "convenient endpoint registration"
  end

  describe "#endpoints?" do
    subject { service.endpoints? }

    context "when endpoint are not registered" do
      it { is_expected.to eq(false) }
    end

    context "when endpoint are registered" do
      before { service.register(endpoint_id, verb, path) }

      it { is_expected.to eq(true) }
    end
  end

  describe "#==" do
    let(:other)     { described_class.new(other_id, other_uri) }
    let(:other_id)  { :another }
    let(:other_uri) { "service/:with/endpoints" }

    context "when `other` have same id" do
      let(:other_id) { service_id }

      specify { expect(service).to eq(other) }
    end

    context "when `other` has a different id" do
      specify { expect(service).not_to eq(other) }
    end
  end

  describe "#hash" do
    subject(:hash) { service.hash }

    it { is_expected.to be_a(Integer) }
  end

  describe "#to_s" do
    subject(:to_s) { service.to_s }

    let(:expected_output) do
      "#<StubRequests::Service id=abstractions" \
      " uri=https://abstractions.com/v1 endpoints=[]>"
    end

    context "when no endpoints are registered" do
      it { is_expected.to eq(expected_output) }
    end

    context "when endpoints are registered" do
      before { service.register(endpoint_id, verb, path) }

      let(:expected_output) do
        "#<StubRequests::Service id=abstractions uri=https://abstractions.com/v1 endpoints=[" \
          "#<StubRequests::Endpoint id=:concrete verb=:get path='concretes/:concrete_id'>" \
        "]>"
      end

      it { is_expected.to eq(expected_output) }
    end
  end
end

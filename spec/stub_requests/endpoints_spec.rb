# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Endpoints do
  let(:endpoints)    { described_class.new }
  let(:endpoint)     { StubRequests::Endpoint.new(endpoint_id, verb, uri_template) }
  let(:endpoint_id)  { :resource_collection }
  let(:verb)         { :get }
  let(:uri_template) { "resource/:resource_id/collection" }

  describe "#initialize" do
    its(:endpoints) { is_expected.to be_a(Concurrent::Map) }
  end

  describe "#register" do
    subject(:register) { endpoints.register(endpoint) }

    it "registers the endpoint in the collection" do
      expect { register }.to change { endpoints.endpoints.size }.by(1)
      expect(register).to eq(endpoint)
    end
  end

  describe "#registered?" do
    subject(:registered) { endpoints.registered?(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(false) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint) }

      it { is_expected.to eq(true) }
    end
  end

  describe "#get" do
    subject(:get) { endpoints.get(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#get!" do
    subject(:get) { endpoints.get!(endpoint_id) }

    context "when endpoint is unregistered" do
      specify do
        expect { get }.to raise_error(
          StubRequests::EndpointNotFound,
          "Couldn't find an endpoint with id=:resource_collection",
        )
      end
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#update" do
    subject(:update) { endpoints.update(endpoint_id, new_verb, new_uri_template, new_default_options) }

    let(:new_verb)            { :post }
    let(:new_uri_template)    { "resource/:resource_id" }
    let(:new_default_options) { { response: { body: "" } } }

    context "when endpoint is unregistered" do
      specify do
        expect { update }.to raise_error(
          StubRequests::EndpointNotFound,
          "Couldn't find an endpoint with id=:resource_collection",
        )
      end
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint) }

      its(:id) { is_expected.to eq(endpoint_id) }
      its(:verb) { is_expected.to eq(new_verb) }
      its(:uri_template) { is_expected.to eq(new_uri_template) }
      its(:default_options) { is_expected.to eq(new_default_options) }
    end
  end

  describe "#remove" do
    subject(:remove) { endpoints.remove(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      before { endpoints.register(endpoint) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#to_s" do
    subject(:to_s) { endpoints.to_s }

    context "when no endpoints are registered" do
      it { is_expected.to eq("#<StubRequests::Endpoints endpoints=[]>") }
    end

    context "when endpoints are registered" do
      let(:endpoint_two) { StubRequests::Endpoint.new(:bogus_id, :any, "documents/:document_id") }

      before do
        endpoints.register(endpoint)
        endpoints.register(endpoint_two)
      end

      # rubocop:disable Metrics/LineLength
      specify do
        expect(to_s).to eq(
          "#<StubRequests::Endpoints endpoints=[" \
          "#<StubRequests::Endpoint id=:resource_collection verb=:get uri_template='resource/:resource_id/collection'>," \
          "#<StubRequests::Endpoint id=:bogus_id verb=:any uri_template='documents/:document_id'>" \
          "]>",
        )
      end
      # rubocop:enable Metrics/LineLength
    end
  end
end

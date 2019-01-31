# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Service do
  let(:service)         { described_class.new(service_id, service_uri) }
  let(:service_id)      { :abstractions }
  let(:service_uri)     { "https://abstractions.com/v1" }
  let(:endpoint_id)     { :concrete }
  let(:verb)            { :get }
  let(:uri_template)    { "concretes/:concrete_id" }
  let(:default_options) { {} }

  describe "#initialize" do
    subject { service }

    its(:id) { is_expected.to eq(service_id) }
    its(:uri) { is_expected.to eq(service_uri) }
  end

  describe "#register_endpoint" do
    subject(:register_endpoint) { service.register_endpoint(endpoint_id, verb, uri_template, default_options) }

    let(:endpoint_id)     { :concrete }
    let(:verb)            { :get }
    let(:uri_template)    { "concretes/:concrete_id" }
    let(:default_options) { {} }

    context "when endpoint is unregistered" do
      it { is_expected.to be_a(StubRequests::Endpoint) }
      its(:id) { is_expected.to eq(endpoint_id) }
      its(:verb) { is_expected.to eq(verb) }
      its(:uri_template) { is_expected.to eq(uri_template) }
      its(:default_options) { is_expected.to eq(default_options) }
    end

    context "when endpoint is registered" do
      before { service.register_endpoint(endpoint_id, old_verb, old_uri_template, old_default_options) }

      let(:old_verb)            { :post }
      let(:old_uri_template)    { "concrete" }
      let(:old_default_options) { { request: { body: "" } } }

      its(:id) { is_expected.to eq(endpoint_id) }
      its(:verb) { is_expected.to eq(verb) }
      its(:uri_template) { is_expected.to eq(uri_template) }
      its(:default_options) { is_expected.to eq(default_options) }
    end
  end

  describe "#get_endpoint" do
    subject(:get_endpoint) { service.get_endpoint(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      let!(:endpoint) { service.register_endpoint(endpoint_id, verb, uri_template, default_options) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#get_endpoint!" do
    subject(:get_endpoint) { service.get_endpoint!(endpoint_id) }

    context "when endpoint is unregistered" do
      specify do
        expect { get_endpoint }.to raise_error(
          StubRequests::EndpointNotFound,
          "Couldn't find an endpoint with id=:concrete",
        )
      end
    end

    context "when endpoint is registered" do
      let!(:endpoint) { service.register_endpoint(endpoint_id, verb, uri_template, default_options) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#to_s" do
    subject(:to_s) { service.to_s }

    context "when no endpoints are registered" do
      it { is_expected.to eq("#<StubRequests::Service id=abstractions uri=https://abstractions.com/v1 endpoints=[]>") }
    end

    context "when endpoints are registered" do
      before { service.register_endpoint(endpoint_id, verb, uri_template, default_options) }

      specify do
        expect(to_s).to eq(
          "#<StubRequests::Service id=abstractions uri=https://abstractions.com/v1" \
          " endpoints=[#<StubRequests::Endpoint id=:concrete verb=:get uri_template='concretes/:concrete_id'>]>",
        )
      end
    end
  end
end

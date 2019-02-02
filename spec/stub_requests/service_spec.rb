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

  describe "#register" do
    subject(:register) { service.endpoints.register(endpoint_id, verb, uri_template, default_options) }

    let(:endpoint_id)     { :concrete }
    let(:verb)            { :get }
    let(:uri_template)    { "concretes/:concrete_id" }
    let(:default_options) { {} }

    context "when endpoint is unregistered" do
      it { is_expected.to be_a(StubRequests::Endpoint) }

      its(:id)           { is_expected.to eq(endpoint_id) }
      its(:verb)         { is_expected.to eq(verb) }
      its(:uri_template) { is_expected.to eq(uri_template) }
      its(:options)      { is_expected.to eq(default_options) }
    end

    context "when endpoint is registered" do
      before { service.endpoints.register(endpoint_id, old_verb, old_uri_template, old_default_options) }

      let(:old_verb)            { :post }
      let(:old_uri_template)    { "concrete" }
      let(:old_default_options) { { request: { body: "" } } }

      its(:id)           { is_expected.to eq(endpoint_id) }
      its(:verb)         { is_expected.to eq(verb) }
      its(:uri_template) { is_expected.to eq(uri_template) }
      its(:options)      { is_expected.to eq(default_options) }
    end
  end

  describe "#find_endpoint" do
    subject(:find_endpoint) { service.endpoints.find(endpoint_id) }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(nil) }
    end

    context "when endpoint is registered" do
      let!(:endpoint) { service.endpoints.register(endpoint_id, verb, uri_template, default_options) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#endpoints?" do
    subject { service.endpoints? }

    context "when endpoint is unregistered" do
      it { is_expected.to eq(false) }
    end

    context "when endpoint is registered" do
      before { service.endpoints.register(endpoint_id, verb, uri_template, default_options) }

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

  describe "#find_endpoint!" do
    subject(:find_endpoint) { service.endpoints.find!(endpoint_id) }

    context "when endpoint is unregistered" do
      let(:error)   { StubRequests::EndpointNotFound }
      let(:message) { "Couldn't find an endpoint with id=:concrete" }

      it! { is_expected.to raise_error(error, message) }
    end

    context "when endpoint is registered" do
      let!(:endpoint) { service.endpoints.register(endpoint_id, verb, uri_template, default_options) }

      it { is_expected.to eq(endpoint) }
    end
  end

  describe "#hash" do
    subject(:hash) { service.hash }

    it { is_expected.to be_a(Integer) }
  end

  describe "#to_s" do
    subject(:to_s) { service.to_s }

    context "when no endpoints are registered" do
      it { is_expected.to eq("#<StubRequests::Service id=abstractions uri=https://abstractions.com/v1 endpoints=[]>") }
    end

    context "when endpoints are registered" do
      before { service.endpoints.register(endpoint_id, verb, uri_template, default_options) }

      let(:expected_output) do
        "#<StubRequests::Service id=abstractions uri=https://abstractions.com/v1" \
        " endpoints=[#<StubRequests::Endpoint id=:concrete verb=:get uri_template='concretes/:concrete_id'>]>"
      end

      it { is_expected.to eq(expected_output) }
    end
  end
end

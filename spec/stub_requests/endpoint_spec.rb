# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Endpoint do
  let(:endpoint) { described_class.new(service, endpoint_id, verb, path, default_options) }

  let(:service)         { StubRequests::Service.new(service_id, service_uri) }
  let(:service_id)      { :an_api }
  let(:service_uri)     { "https://an_api.na/v1" }
  let(:endpoint_id)     { :resource_collection }
  let(:verb)            { :get }
  let(:path)            { "resource/:resource_id/collection" }
  let(:default_options) { { request: { headers: { "Accept" => "no/bullshit" } } } }

  describe "#initialize" do
    subject { endpoint }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(verb) }
    its(:path) { is_expected.to eq(path) }
    its(:options)      { is_expected.to eq(default_options) }
  end

  describe "#update" do
    subject(:update) { endpoint.update(new_verb, new_path, new_default_options) }

    let(:new_verb) { :patch }
    let(:new_path)            { "resource/:resource_id/collection/:collection_id" }
    let(:new_default_options) { { response: { body: "" } } }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(new_verb) }
    its(:path) { is_expected.to eq(new_path) }
    its(:options) { is_expected.to eq(new_default_options) }
  end

  describe "#==" do
    let(:other)     { described_class.new(service, other_id, verb, path, default_options) }
    let(:other_id)  { :another }
    let(:other_uri) { "endpoint/:with/endpoints" }

    context "when `other` have same id" do
      let(:other_id) { endpoint_id }

      specify { expect(endpoint).to eq(other) }
    end

    context "when `other` has a different id" do
      specify { expect(endpoint).not_to eq(other) }
    end
  end

  describe "#hash" do
    subject(:hash) { endpoint.hash }

    it { is_expected.to be_a(Integer) }
  end

  describe "#to_s" do
    subject(:to_s) { endpoint.to_s }

    let(:expected_output) do
      "#<StubRequests::Endpoint id=:resource_collection" \
      " verb=:get path='resource/:resource_id/collection'>"
    end

    it { is_expected.to eq(expected_output) }
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Registration::Endpoint do
  let(:endpoint) { described_class.new(endpoint_id, verb, uri_template, default_options) }

  let(:endpoint_id)     { :resource_collection }
  let(:verb)            { :get }
  let(:uri_template)    { "resource/:resource_id/collection" }
  let(:default_options) { { request: { headers: { "Accept" => "no/bullshit" } } } }

  describe "#initialize" do
    subject { endpoint }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(verb) }
    its(:uri_template) { is_expected.to eq(uri_template) }
    its(:options)      { is_expected.to eq(default_options) }
  end

  describe "#update" do
    subject(:update) { endpoint.update(new_verb, new_uri_template, new_default_options) }

    let(:new_verb)            { :patch }
    let(:new_uri_template)    { "resource/:resource_id/collection/:collection_id" }
    let(:new_default_options) { { response: { body: "" } } }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(new_verb) }
    its(:uri_template) { is_expected.to eq(new_uri_template) }
    its(:options)      { is_expected.to eq(new_default_options) }
  end

  describe "#==" do
    let(:other)     { described_class.new(other_id, verb, uri_template, default_options) }
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
      "#<StubRequests::Registration::Endpoint id=:resource_collection" \
      " verb=:get uri_template='resource/:resource_id/collection'>"
    end

    it { is_expected.to eq(expected_output) }
  end
end

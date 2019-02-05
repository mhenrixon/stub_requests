# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Endpoint do
  let(:endpoint) { described_class.new(endpoint_id, verb, uri_template) }

  let(:endpoint_id)     { :resource_collection }
  let(:verb)            { :get }
  let(:uri_template)    { "resource/:resource_id/collection" }

  describe "#initialize" do
    subject { endpoint }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(verb) }
    its(:uri_template) { is_expected.to eq(uri_template) }
  end

  describe "#update" do
    subject(:update) { endpoint.update(new_verb, new_uri_template) }

    let(:new_verb)            { :patch }
    let(:new_uri_template)    { "resource/:resource_id/collection/:collection_id" }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(new_verb) }
    its(:uri_template) { is_expected.to eq(new_uri_template) }
  end

  describe "#==" do
    let(:other)     { described_class.new(other_id, verb, uri_template) }
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
      " verb=:get uri_template='resource/:resource_id/collection'>"
    end

    it { is_expected.to eq(expected_output) }
  end
end

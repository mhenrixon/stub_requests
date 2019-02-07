# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Endpoint do
  let(:endpoint) { described_class.new(endpoint_attributes) }

  let(:service_id)  { :google }
  let(:endpoint_id) { :todos_show }
  let(:verb)        { :get }
  let(:path)        { "todos/:id" }
  let(:service_uri) { "https://google.com/keep/v1" }

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
    subject { endpoint }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(verb) }
    its(:path) { is_expected.to eq(path) }
  end

  describe "#update" do
    subject(:update) { endpoint.update(new_verb, new_path) }

    let(:new_verb) { :patch }
    let(:new_path) { "resource/:resource_id/collection/:collection_id" }

    its(:id)           { is_expected.to eq(endpoint_id) }
    its(:verb)         { is_expected.to eq(new_verb) }
    its(:path) { is_expected.to eq(new_path) }
  end

  describe "#==" do
    let(:other)      { described_class.new(other_attributes) }
    let(:other_id)   { :another }
    let(:other_path) { "endpoint/:with/endpoints" }

    let(:other_attributes) do
      endpoint_attributes.merge(
        endpoint_id: other_id,
        path: other_path,
      )
    end

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
      "#<StubRequests::Endpoint id=:todos_show" \
      " verb=:get path='todos/:id'>"
    end

    it { is_expected.to eq(expected_output) }
  end
end

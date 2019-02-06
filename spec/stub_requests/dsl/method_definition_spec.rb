# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::DSL::MethodDefinition do
  let(:instance) { described_class.new(service_id, endpoint_id, route_params) }

  let(:service_id)   { :documents }
  let(:endpoint_id)  { :show }
  let(:route_params) { [:id] }

  describe "#initialize" do
    subject { instance }

    it { is_expected.to respond_to(:service_id) }
    it { is_expected.to respond_to(:endpoint_id) }
    it { is_expected.to respond_to(:route_params) }
    it { is_expected.to respond_to(:name) }
    it { is_expected.to respond_to(:to_s) }

    its(:service_id)   { is_expected.to eq(:documents) }
    its(:endpoint_id)  { is_expected.to eq(:show) }
    its(:route_params) { is_expected.to eq([:id]) }
  end

  describe "#to_s" do
    subject(:to_s) { instance.to_s }

    context "when given no route parameter" do
      let(:route_params) { [] }

      specify do
        is_expected.to eq(<<~METHOD)
          def stub_show(&block)
            stub_endpoint(:documents, :show, &block)
          end
        METHOD
      end
    end

    context "when given a complex example" do
      let(:route_params) { [:person_id, :id] }
      let(:service_id)   { :custom_api }
      let(:endpoint_id)  { :person_documents_show }

      specify do
        is_expected.to eq(<<~METHOD)
          def stub_person_documents_show(person_id:, id:, &block)
            stub_endpoint(:custom_api, :person_documents_show, person_id: person_id, id: id, &block)
          end
        METHOD
      end
    end
  end
end

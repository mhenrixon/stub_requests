# frozen_string_literal: true

require "spec_helper"

module RecevingModule; end

RSpec.describe StubRequests::DSL::DefineMethod do
  let(:instance)   { described_class.new(definition, receiver) }
  let(:receiver)   { RecevingModule }
  let(:definition) { StubRequests::DSL::MethodDefinition.new(endpoint_id, route_params) }

  let(:endpoint_id)  { :todos_show }
  let(:route_params) { [:id] }

  describe "#initialize" do
    subject { instance }

    it { is_expected.to respond_to(:receiver) }
    it { is_expected.to respond_to(:define) }
    it { is_expected.to respond_to(:definition) }

    its(:receiver)   { is_expected.to eq(receiver) }
    its(:definition) { is_expected.to eq(definition) }
  end

  describe "#define" do
    subject(:define) { instance.define }

    before do
      allow(receiver).to receive(:module_eval)
      allow(receiver).to receive(:silence_redefinition_of_method).with(definition.name)
    end

    it "calls .module_eval on the receiver" do # rubocop:disable RSpec/ExampleLength
      define

      expect(receiver).to have_received(:module_eval).with(
        a_string_including(definition),
        kind_of(String),
        kind_of(Integer),
      )
    end
  end
end

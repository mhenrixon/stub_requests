require "spec_helper"

RSpec.describe StubRequests::ArgumentValidation do
  describe ".validate!" do
    subject { described_class.validate!(argument)  }

    let(:name)  { :arg }
    let(:type)  { Symbol }
    let(:value) { :sym }
    let(:arity) { nil }
    let(:argument) do
      {
        name: name,
        type: type,
        value: value,
        arity: arity,
      }
    end

    it! { is_expected.not to raise_error }
  end
end

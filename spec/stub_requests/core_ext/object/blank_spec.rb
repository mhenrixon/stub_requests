# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Object do
  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  it { is_expected.not_to be_blank }
  it { is_expected.to be_present }

  its(:presence) { is_expected.to eq(subject) }
end

RSpec.describe NilClass do
  subject { nil }

  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  it { is_expected.to be_blank }
  it { is_expected.not_to be_present }
  its(:presence) { is_expected.to eq(subject) }
end

RSpec.describe FalseClass do
  subject { false }

  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  it { is_expected.to be_blank }
  it { is_expected.not_to be_present }

  its(:presence) { is_expected.to eq(nil) }
end

RSpec.describe TrueClass do
  subject { true }

  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  it { is_expected.not_to be_blank }
  it { is_expected.to be_present }
  its(:presence) { is_expected.to eq(subject) }
end

RSpec.describe Array do
  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  context "with an empty array" do
    subject { [] }

    it { is_expected.to be_blank }
    it { is_expected.not_to be_present }
    its(:presence) { is_expected.to eq(nil) }
  end

  context "with an array containing items" do
    subject { %i[item] }

    it { is_expected.not_to be_blank }
    it { is_expected.to be_present }
    its(:presence) { is_expected.to eq(subject) }
  end
end

RSpec.describe Hash do
  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  context "with an empty hash" do
    it { is_expected.to be_blank }
    it { is_expected.not_to be_present }
    its(:presence) { is_expected.to eq(nil) }
  end

  context "with a hash containing keys" do
    subject { { key: :val } }

    it { is_expected.not_to be_blank }
    it { is_expected.to be_present }
    its(:presence) { is_expected.to eq(subject) }
  end
end

RSpec.describe String do
  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  context "with an empty string" do
    it { is_expected.to be_blank }
    it { is_expected.not_to be_present }
    its(:presence) { is_expected.to eq(nil) }
  end

  context "with a string containing characters" do
    subject { "I am a string" }

    it { is_expected.not_to be_blank }
    it { is_expected.to be_present }
    its(:presence) { is_expected.to eq(subject) }
  end
end

RSpec.describe Numeric do
  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  it { is_expected.not_to be_blank }
  it { is_expected.to be_present }
  its(:presence) { is_expected.to eq(subject) }
end

RSpec.describe Time do
  it { is_expected.to respond_to(:blank?) }
  it { is_expected.to respond_to(:present?) }
  it { is_expected.to respond_to(:presence) }

  it { is_expected.not_to be_blank }
  it { is_expected.to be_present }
  its(:presence) { is_expected.to eq(subject) }
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Property, ".property" do
  subject { test_class }

  let(:test_instance) { test_class.new }
  let(:test_class) do
    class TestProperty
      include StubRequests::Property
    end
  end

  let(:property_name)    { :a_method }
  let(:property_type)    { String }
  let(:property_default) { "test string" }

  before do
    Docile.dsl_eval(test_class) do
      property property_name, type: property_type, default: property_default
    end
  end

  describe ".properties" do
    let(:properties) { { property_name => { type: [property_type], default: property_default } } }

    context "for class" do
      subject { test_class }

      its(:properties) { are_expected.to eq(properties) }
    end

    context "for instance" do
      subject { test_instance }

      its(:properties) { are_expected.to eq(properties) }
    end
  end

  describe ".property_predicate" do
    subject { test_instance.public_send(:"#{property_name}?") }

    it { is_expected.to eq(true) }
  end

  describe ".property_reader" do
    subject { test_instance.public_send(property_name) }

    it { is_expected.to eq("test string") }
  end

  describe ".property_writer" do
    subject { test_instance.public_send("#{property_name}=", new_value) }

    let(:new_value) { "another string" }

    it { is_expected.to eq("another string") }
  end

  describe ":default" do
    context "when property_type matches :type" do
      subject { test_instance.public_send(property_name) }

      it { is_expected.to eq(property_default) }
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

module API
  module Stubs
    module Internal
      module Documents
      end
    end
  end
end

class Testing; end

# rubocop:disable RSpec/MultipleExpectations
RSpec.describe StubRequests::DSL do
  let(:dsl)           { described_class.new(service_id, receiver: stub_module) }
  let(:test_instance) { Testing.new }
  let(:stub_module)   { API::Stubs::Internal::Documents }
  let(:service_id)    { :person_documents_internal }
  let(:service_uri)   { "https://domain.com/api/internal" }

  before do
    StubRequests.register_service(service_id, service_uri) do
      get    "persons/:person_id/documents/:id", as: :person_documents_show
      get    "persons/:person_id/documents",     as: :person_documents_index
      post   "persons/:person_id/documents",     as: :person_documents_create
      patch  "persons/:person_id/documents/:id", as: :person_documents_patch
      delete "persons/:person_id/documents/:id", as: :person_documents_destroy
    end
  end

  describe "#initialize" do
    subject { dsl }

    its(:receiver)  { is_expected.to eq(stub_module) }
    its(:endpoints) { is_expected.to be_a(Array) }

    its("endpoints.size") { is_expected.to eq(5) }
  end

  describe "#define_stubs" do
    subject(:test_instance) { Testing.new }

    before do
      dsl.define_stubs
      Testing.send(:include, stub_module)
    end

    it { expect(Testing.included_modules).to include(stub_module) }
    it { is_expected.to respond_to(:stub_person_documents_create).with_keywords(:person_id) }
    it { is_expected.to respond_to(:stub_person_documents_show).with_keywords(:person_id, :id) }
    it { is_expected.to respond_to(:stub_person_documents_index).with_keywords(:person_id) }
    it { is_expected.to respond_to(:stub_person_documents_patch).with_keywords(:person_id, :id) }
    it { is_expected.to respond_to(:stub_person_documents_destroy).with_keywords(:person_id, :id) }

    describe "#stub_person_documents_create" do
      it "stubs WebMock with the right request details" do
        test_instance.stub_person_documents_create(person_id: "abcdef") do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/abcdef/documents")
          expect(request_pattern.method_pattern.to_s).to eq("post")
        end
      end
    end

    describe "#stub_person_documents_show" do
      it "stubs WebMock with the right request details" do
        test_instance.stub_person_documents_show(person_id: "456", id: "123") do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/456/documents/123")
          expect(request_pattern.method_pattern.to_s).to eq("get")
        end
      end
    end

    describe "#stub_person_documents_index" do
      it "stubs WebMock with the right request details" do
        test_instance.stub_person_documents_index(person_id: "631") do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/631/documents")
          expect(request_pattern.method_pattern.to_s).to eq("get")
        end
      end
    end

    describe "#stub_person_documents_patch" do
      it "stubs WebMock with the right request details" do
        test_instance.stub_person_documents_patch(person_id: 789, id: 321) do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/789/documents/321")
          expect(request_pattern.method_pattern.to_s).to eq("patch")
        end
      end
    end

    describe "#stub_person_documents_destroy" do
      it "stubs WebMock with the right request details" do
        test_instance.stub_person_documents_destroy(person_id: 789, id: 321) do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/789/documents/321")
          expect(request_pattern.method_pattern.to_s).to eq("delete")
        end
      end
    end
  end

  describe "#print_stubs" do
    subject(:print_stubs) { dsl.print_stubs }

    let(:stub_person_documents_create) do
      a_string_including(<<~METHOD)
        def stub_person_documents_create(person_id:, &block)
          StubRequests.stub_endpoint(:person_documents_create, person_id: person_id, &block)
        end
      METHOD
    end

    let(:stub_person_documents_show) do
      a_string_including(<<~METHOD)
        def stub_person_documents_show(person_id:, id:, &block)
          StubRequests.stub_endpoint(:person_documents_show, person_id: person_id, id: id, &block)
        end
      METHOD
    end

    let(:stub_person_documents_index) do
      a_string_including(<<~METHOD)
        def stub_person_documents_index(person_id:, &block)
          StubRequests.stub_endpoint(:person_documents_index, person_id: person_id, &block)
        end
      METHOD
    end

    let(:stub_person_documents_patch) do
      a_string_including(<<~METHOD)
        def stub_person_documents_patch(person_id:, id:, &block)
          StubRequests.stub_endpoint(:person_documents_patch, person_id: person_id, id: id, &block)
        end
      METHOD
    end

    let(:stub_person_documents_destroy) do
      a_string_including(<<~METHOD)
        def stub_person_documents_destroy(person_id:, id:, &block)
          StubRequests.stub_endpoint(:person_documents_destroy, person_id: person_id, id: id, &block)
        end
      METHOD
    end

    it! { is_expected.to output(stub_person_documents_create).to_stdout }
    it! { is_expected.to output(stub_person_documents_show).to_stdout }
    it! { is_expected.to output(stub_person_documents_index).to_stdout }
    it! { is_expected.to output(stub_person_documents_patch).to_stdout }
    it! { is_expected.to output(stub_person_documents_destroy).to_stdout }
  end
end
# rubocop:enable RSpec/MultipleExpectations

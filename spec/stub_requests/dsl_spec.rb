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

# rubocop:disable RSpec/MultipleExpectations
RSpec.describe StubRequests::DSL do
  describe ".define_endpoint_methods" do
    class Testing; end

    subject(:document_api) do
      Testing.send(:include, stub_module)
      Testing.new
    end

    let(:stub_module) { API::Stubs::Internal::Documents }

    let(:service_id)  { :person_documents_internal }
    let(:service_uri) { "https://domain.com/api/internal" }

    before do
      StubRequests.register_service(service_id, service_uri) do
        register :person_documents_show,   :get,    "persons/:person_id/documents/:id"
        register :person_documents_index,  :get,    "persons/:person_id/documents"
        register :person_documents_create, :post,   "persons/:person_id/documents"
        register :person_documents_patch,  :patch,  "persons/:person_id/documents/:id"
        register :person_documents_delete, :delete, "persons/:person_id/documents/:id"
      end

      ::StubRequests::DSL.define_endpoint_methods(service_id, receiver: stub_module)
      document_api
    end

    it { expect(Testing.included_modules).to include(stub_module) }
    it { is_expected.to respond_to(:stub_person_documents_create).with_keywords(:person_id) }
    it { is_expected.to respond_to(:stub_person_documents_show).with_keywords(:person_id, :id) }
    it { is_expected.to respond_to(:stub_person_documents_index).with_keywords(:person_id) }
    it { is_expected.to respond_to(:stub_person_documents_patch).with_keywords(:person_id, :id) }
    it { is_expected.to respond_to(:stub_person_documents_delete).with_keywords(:person_id, :id) }

    describe "#stub_person_documents_create" do
      it "stubs WebMock with the right request details" do
        document_api.stub_person_documents_create(person_id: "abcdef") do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/abcdef/documents")
          expect(request_pattern.method_pattern.to_s).to eq("post")
        end
      end
    end

    describe "#stub_person_documents_show" do
      it "stubs WebMock with the right request details" do
        document_api.stub_person_documents_show(person_id: "456", id: "123") do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/456/documents/123")
          expect(request_pattern.method_pattern.to_s).to eq("get")
        end
      end
    end

    describe "#stub_person_documents_index" do
      it "stubs WebMock with the right request details" do
        document_api.stub_person_documents_index(person_id: "631") do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/631/documents")
          expect(request_pattern.method_pattern.to_s).to eq("get")
        end
      end
    end

    describe "#stub_person_documents_patch" do
      it "stubs WebMock with the right request details" do
        document_api.stub_person_documents_patch(person_id: 789, id: 321) do
          expect(self).to be_a(WebMock::RequestStub)
          expect(request_pattern.uri_pattern.to_s).to eq("https://domain.com/api/internal/persons/789/documents/321")
          expect(request_pattern.method_pattern.to_s).to eq("patch")
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleExpectations

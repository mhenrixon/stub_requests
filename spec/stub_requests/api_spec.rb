# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::API do
  let(:service_registry) { StubRequests::ServiceRegistry.instance }
  let(:service_id)       { :api }
  let(:service_uri)      { "https://api.com/v1" }
  let(:verb)             { :get }
  let(:uri)              { "http://service-less:9292/internal/accounts/acoolaccountuid" }
  let(:request_query)    { nil }
  let(:request_body)     { nil }
  let(:request_headers)  { nil }
  let(:response_status)  { 200 }
  let(:response_headers) { nil }
  let(:response_body)    { nil }
  let(:error)            { nil }
  let(:options) do
    {
      request: request_options,
      response: response_options,
      error: error,
    }
  end
  let(:request_options) do
    {
      query: request_query,
      body: request_body,
      headers: request_headers,
    }
  end
  let(:response_options) do
    {
      status: response_status,
      headers: response_headers,
      body: response_body,
    }
  end

  describe "#define_stubs" do
    subject(:define_stubs) { described_class.define_stubs(service_id, receiver: stub_module) }

    let(:dsl) { StubRequests::DSL.new(service_id, receiver: stub_module) }
    let(:stub_module) { Class.new(Module) }

    before do
      StubRequests.register_service(service_id, service_uri)

      allow(StubRequests::DSL).to receive(:new)
        .with(service_id, receiver: stub_module)
        .and_return(dsl)

      allow(dsl).to receive(:define_stubs)

      define_stubs
    end

    it "delegates to DSL#define_stubs" do
      expect(dsl).to have_received(:define_stubs)
    end
  end

  describe "#print_stubs" do
    subject(:print_stubs) { described_class.print_stubs(service_id) }

    let(:stub_module) { Class.new(Module) }
    let(:dsl) { StubRequests::DSL.new(service_id, receiver: stub_module) }

    before do
      StubRequests.register_service(service_id, service_uri)

      allow(StubRequests::DSL).to receive(:new)
        .with(service_id)
        .and_return(dsl)

      allow(dsl).to receive(:print_stubs)

      print_stubs
    end

    it "delegates to DSL#print_stubs" do
      expect(dsl).to have_received(:print_stubs)
    end
  end

  describe "#register_service" do
    subject(:register_service) do
      described_class.register_service(service_id, service_uri)
    end

    shared_examples "a successful registration" do
      it { is_expected.to be_a(StubRequests::Service) }

      its(:id)  { is_expected.to eq(service_id) }
      its(:uri) { is_expected.to eq(service_uri) }

      it! { is_expected.to change(service_registry, :count).by(1) }
    end

    it_behaves_like "a successful registration"

    context "when given a block" do
      specify { register_service { expect(self).to be_a(StubRequests::Endpoints) } }

      it_behaves_like "a successful registration"
    end
  end

  describe "#stub_endpoint" do
    subject(:stub_endpoint) do
      described_class.stub_endpoint(service_id, endpoint_id, route_params)
    end

    let(:endpoint_id)      { :files }
    let(:verb)             { :get }
    let(:path)             { "files/:file_id" }
    let(:route_params)     { { file_id: 100 } }
    let(:service)          { nil }
    let(:block)            { nil }

    context "when service is unregistered" do
      let(:error)   { StubRequests::ServiceNotFound }
      let(:message) { "Couldn't find a service with id=:api" }

      it! { is_expected.to raise_error(error, message) }
    end

    context "when service is registered" do
      let!(:service) { described_class.register_service(service_id, service_uri) }

      context "when endpoint is registered" do
        let!(:endpoint) { service.endpoints.register(endpoint_id, verb, path) } # rubocop:disable RSpec/LetSetup

        it { is_expected.to be_a(WebMock::RequestStub) }
      end

      context "when given a block" do
        let!(:endpoint) { service.endpoints.register(endpoint_id, verb, path) } # rubocop:disable RSpec/LetSetup

        it "yields the stub to the block" do
          stub_endpoint do |stub|
            expect(stub).to be_a(WebMock::RequestStub)
          end
        end
      end

      context "when endpoint is unregistered" do
        let(:error)   { StubRequests::EndpointNotFound }
        let(:message) { "Couldn't find an endpoint with id=:files" }

        it! { is_expected.to raise_error(error, message) }
      end
    end
  end

  describe "#register_callback" do
    subject(:register_callback) do
      described_class.register_callback(service_id, endpoint_id, verb, callback)
    end

    let(:service_id)  { :random_api }
    let(:endpoint_id) { :files }
    let(:verb)        { :get }
    let(:callback)    { -> {} }

    before do
      allow(StubRequests::CallbackRegistry).to receive(:register)
      register_callback
    end

    it "delegates to StubRequests::CallbackRegistry.register" do
      expect(StubRequests::CallbackRegistry).to have_received(:register)
        .with(service_id, endpoint_id, verb, callback)
    end
  end

  describe "#unregister_callback" do
    subject(:unregister_callback) do
      described_class.unregister_callback(service_id, endpoint_id, verb)
    end

    let(:service_id)  { :random_api }
    let(:endpoint_id) { :files }
    let(:verb)        { :get }

    before do
      allow(StubRequests::CallbackRegistry).to receive(:unregister)
      unregister_callback
    end

    it "delegates to StubRequests::CallbackRegistry.unregister" do
      expect(StubRequests::CallbackRegistry).to have_received(:unregister)
        .with(service_id, endpoint_id, verb)
    end
  end
end

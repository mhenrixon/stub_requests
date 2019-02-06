# frozen_string_literal: true

module StubRequests
  #
  # Module DSL takes the id of a registered service
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  # @since 0.1.4
  #
  # @example **Register service with endpoints**
  #   StubRequests.register_service(:documents, "https://company.com/api/v1") do
  #     register_endpoints do
  #       get "documents/:id", as: :documents_show
  #       get "documents",     as: :documents_index
  #       post "documents",    as: :documents_create
  #     end
  #   end
  # @example **Create a receiver module for the stub methods**
  #   module Stubs; end
  #
  #   Stubs.instance_methods #=> []
  # @example **Define the endpoint methods using the DSL**
  #   StubRequests::DSL.define_stubs(
  #     :documents, receiver: Stubs
  #   )
  #
  #   # This turns the module Stubs into the following:
  #
  #   Stubs.instance_methods #=> [:stub_documents_show, :stub_documents_index, :stub_documents_create]
  #   module Stubs
  #     def stub_documents_show(id:, &block)
  #        stub_endpoint(:documents, :show, id: id, &block)
  #     end
  #
  #     def stub_documents_index(&block)
  #        stub_endpoint(:documents, :index, &block)
  #     end
  #
  #     def stub_documents_create(&block)
  #        stub_endpoint(:documents, :create, &block)
  #     end
  #    end
  #
  # @example **Use the helper methods in your tests**
  #   include Stubs
  #
  #   let(:document_id)   { 1234 }
  #   let(:request_body)  { { key: "value" }.to_json }
  #   let(:response_body) { { id: document_id, key: "value" }.to_json }
  #
  #   before do
  #     stub_documents_create do
  #       with(body: request_body)
  #       to_return(body: response_body)
  #     end
  #
  #     stub_documents_show(id: document_id) do
  #       with(body: request_body)
  #       to_return(body: response_body)
  #     end
  #   end
  #
  #   it "stubs the requests nicely" do
  #     create_uri = URI("https://company.com/api/v1/documents")
  #     response   = Net::HTTP.post(create_uri)
  #     expect(response).to be_json_eql(response_body.to_json)
  #
  #     show_uri = URI("https://company.com/api/v1/documents/#{document_id}")
  #     response = Net::HTTP.post(create_uri)
  #     expect(response).to be_json_eql(response_body.to_json)
  #   end
  class DSL
    #
    # @!attribute [r] service
    #   @return [Service] an instance of a service
    attr_reader :service
    #
    # @!attribute [r] receiver
    #   @return [Module, nil] the receiver module
    attr_reader :receiver
    #
    # @!attribute [r] endpoints
    #   @return [Array<Endpoint>] a collection of endpoints
    attr_reader :endpoints

    #
    # Initialize a new instance of DSL
    #
    # @param [Symbol] service_id the id of a registered service
    # @param [Module] receiver the receiver of the stub methods
    #
    def initialize(service_id, receiver: nil)
      @service   = StubRequests::ServiceRegistry.instance.find!(service_id)
      @receiver  = receiver
      @endpoints = service.endpoints.endpoints.values
    end

    #
    # Defines stub methods for #endpoints in the #receiver
    #
    #
    # @return [void]
    #
    def define_stubs
      receiver.send(:include, StubRequests::API)

      method_definitions.each do |method_definition|
        DefineMethod.new(method_definition, receiver).define
      end
    end

    #
    # Prints stub methods for #endpoints to STDOUT
    #
    #
    # @return [void]
    #
    def print_stubs
      method_definitions.each do |method_definition|
        puts("#{method_definition}\n\n")
      end
    end

    def method_definitions
      @method_definitions ||= endpoints.map do |endpoint|
        MethodDefinition.new(service.id, endpoint.id, endpoint.route_params)
      end
    end
  end
end

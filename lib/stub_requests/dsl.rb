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
  #       register(:show, :get, "documents/:id")
  #       register(:index, :get, "documents")
  #       register(:create, :post, "documents")
  #     end
  #   end
  # @example **Create a receiver module for the stub methods**
  #   module Stubs; end
  #
  #   Stubs.instance_methods #=> []
  # @example **Define the endpoint methods using the DSL**
  #   StubRequests::DSL.define_endpoint_methods(
  #     :documents, receiver: Stubs
  #   )
  #
  #   # This turns the module Stubs into the following:
  #
  #   Stubs.instance_methods #=> [:stub_documents_show, :stub_documents_index, :stub_documents_create]
  #   module Stubs
  #      def stub_documents_show(id:, &block)
  #         stub_endpoint(:documents, :show, id: id, &block)
  #      end
  #
  #      def stub_documents_index(&block)
  #         stub_endpoint(:documents, :index, &block)
  #      end
  #
  #      def stub_documents_create(&block)
  #         stub_endpoint(:documents, :create, &block)
  #      end
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
    BLOCK_ARG = "&block"

    attr_reader :endpoints

    class MethodDefinitionBuilder
      attr_reader :route_params, :endpoint_id, :service_id

      def initialize(endpoint)
        @route_params = endpoint.route_params
        @endpoint_id  = endpoint.id
        @service_id   = endpoint.service_id
      end

      def generate_definition
        <<~METHOD
        def #{method_name}(#{keywords})
          stub_endpoint(:#{service_id}, :#{endpoint_id}, #{arguments})
        end
        METHOD
      end

      def method_name
        @method_name ||= "stub_#{endpoint_id}"
      end

      def keywords
        @keywords ||= route_params.map { |param| "#{param}:" }.concat([+BLOCK_ARG]).join(", ")
      end

      def arguments
        @arguments ||= route_params.map { |param| "#{param}: #{param}" }.concat([+BLOCK_ARG]).join(", ")
      end
    end

    attr_reader :service, :receiver, :endpoints

    def initialize(service_id, receiver:)
      @service   = StubRequests::ServiceRegistry.instance.find(service_id)
      @receiver  = receiver
      @endpoints = service.endpoints.endpoints.values
    end

    def define_endpoint_methods
      receiver.send(:include, StubRequests::API)
      endpoints.each do |endpoint|

      end
    end

    def define_method_for(endpoint)
      method_builder = MethodDefinitionBuilder.new(endpoint)
      Docile.dsl_eval(receiver) do
        silence_redefinition_of_method(method_builder.method_name)
        module_eval <<-METHOD, __FILE__, __LINE__ + 1
          #{method_builder.generate_definition}
        METHOD
      end
    end

    def self.define_endpoint_methods(service_id, receiver:) # rubocop:disable Metrics/MethodLength
      new(service_id, receiver: receiver).define_endpoint_methods
    end
  end
end

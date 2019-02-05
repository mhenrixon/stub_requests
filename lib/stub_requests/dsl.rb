# frozen_string_literal: true

module StubRequests
  #
  # Module DSL takes the id of a registered service
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module DSL
    BLOCK_ARG = "&block"

    #
    # Build convenience methods for all registered service endpoints
    #
    # @param [Symbol] service_id the id of the service
    # @param [Module, Class] receiver of the helper methods
    #
    # @example Define helper methods for stubbing endpoints
    #
    #   StubRequests.register_service(:documents, "https://company.com/api/v1") do
    #     register_endpoints do
    #       register(:show, :get, "documents/:id")
    #       register(:index, :get, "documents")
    #       register(:create, :post, "documents")
    #     end
    #   end
    #
    #   module Stubs
    #   end
    #
    #   Stubs.instance_methods
    #     => []
    #
    #   StubRequests::DSL.define_endpoint_methods(:documents, receiver: Stubs)
    #     => module Stubs
    #          def stub_documents_show(id:, &block)
    #             stub_endpoint(:documents, :show, id: id, &block)
    #          end
    #
    #          def stub_documents_index(&block)
    #             stub_endpoint(:documents, :index, &block)
    #          end
    #
    #          def stub_documents_create(&block)
    #             stub_endpoint(:documents, :create, &block)
    #          end
    #        end
    #
    #
    # @return [Module] the same module as passed in but with methods
    #
    # :reek:DuplicateMethodCall
    # :reek:TooManyStatements
    def self.define_endpoint_methods(service_id, receiver:) # rubocop:disable Metrics/MethodLength
      service   = StubRequests::ServiceRegistry.instance.find(service_id)
      endpoints = service.endpoints

      Docile.dsl_eval_with_block_return(receiver) do
        include StubRequests::API

        endpoints.endpoints.values.each do |endpoint|
          route_params = endpoint.route_params
          keywords     = convert_to_keywords(route_params)
          arguments    = convert_to_arguments(route_params)
          method_name  = "stub_#{endpoint.id}"

          silence_redefinition_of_method(method_name)
          module_eval <<-METHOD, __FILE__, __LINE__ + 1
            def #{method_name}(#{keywords})
              stub_endpoint(:#{endpoint.service_id}, :#{endpoint.id}, #{arguments})
            end
          METHOD
        end
        receiver
      end
      receiver
    end

    # def self.classify(string)
    #   string.to_s.split("_").collect(&:capitalize).join
    # end

    def self.convert_to_keywords(route_params)
      route_params.map { |param| "#{param}:" }.concat([+BLOCK_ARG]).join(", ")
    end

    def self.convert_to_arguments(route_params)
      route_params.map { |param| "#{param}: #{param}" }.concat([+BLOCK_ARG]).join(", ")
    end
  end
end

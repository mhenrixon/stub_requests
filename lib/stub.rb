# frozen_string_literal: true

class Stub
  class HelperRegistry
    extend Forwardable

    include Singleton
    include Enumerable

    delegate [:each, :[], :[]=] => :helpers

    attr_reader :helpers

    def initialize
      @helpers = Concurrent::Map.new
    end
  end

  BLOCK_ARG = "&block"

  def self.define_endpoint_methods(service_id, in_module:)
    service = StubRequests::ServiceRegistry.instance.find!(service_id)

    Docile.dsl_eval_with_block_return(in_module) do
      include StubRequests::API

      service.endpoints.values.each do |endpoint|
        route_params = endpoint.route_params
        keywords     = convert_to_keywords(route_params)
        arguments    = convert_to_arguments(route_params)
        method_name  = "stub_#{endpoint.id}"

        silence_redefinition_of_method(method_name)
        module_eval <<-METHOD, __FILE__, __LINE__ + 1
          def #{method_name}(#{keywords})
            stub_endpoint(:#{endpoint.service.id}, :#{endpoint.id}, #{arguments})
          end
        METHOD
      end
      in_module
    end
    in_module
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

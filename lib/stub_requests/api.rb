# frozen_string_literal: true

module StubRequests
  #
  # Module API abstraction to reduce the amount of WebMock.stub_request
  #
  # @note This module can either be used by its class methods
  #   or included in say RSpec
  #
  # @author Mikael Henriksson <mikael@zoolutions.se>
  #
  module API
    extend self

    include StubRequests::UriFor

    def self.included(base)
      base.send(:extend, self)
    end

    # Return the singleton instance of the {ServiceRegistry}
    # @return [ServiceRegistry] a mocked request
    def service_registry
      ServiceRegistry.instance
    end

    # Register a service in the service registry
    #
    # @param [Symbol] service_id a descriptive id for the service
    # @param [Symbol] service_uri the uri used to call the service
    #
    # @return [Service] a new service or a previously registered service
    #
    def register_service(service_id, service_uri)
      service_registry.register_service(
        Service.new(service_id, service_uri),
      )
    end

    #
    # Stub a request to a registered service endpoint
    #
    # @param [Symbol] service_id the id of a registered service
    # @param [Symbol] endpoint_id the id of a registered endpoint
    # @param [Hash<Symbol>] uri_replacements a list of uri replacements
    # @param [Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request see {#prepare_request}
    # @option options [optional, Hash<Symbol>] :response see {#prepare_response}
    # @option options [optional, Array, Exception, StandardError, String] :error see {#prepare_error}
    # @option options [optional, TrueClass] :timeout if the stubbed request should raise Timeout
    #
    # @example Stub a request to a registered service endpoint
    #   register_stub(
    #     :google_api,
    #     :get_map_location,
    #     { request: { headers: { "Accept" => "application/json" }}},
    #     { response: { body: { id: "abyasdjasd", status: "successful" }}}
    #   )
    #
    # @see #stub_http_request
    # @return [WebMock::RequestStub] a mocked request
    #
    def stub_endpoint(service_id, endpoint_id, uri_replacements = {}, options = {})
      service  = service_registry.get_service!(service_id)
      endpoint = service.get_endpoint!(endpoint_id)
      url      = uri_for(service.uri, endpoint.uri_template, uri_replacements)

      stub_http_request(endpoint.verb, url, options)
    end

    #
    # Stub a HTTP Request with WebMock
    #
    # @param [Symbol] verb the http method
    # @param [String] uri the uri to stub
    # @param [Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>] :request see {#prepare_request}
    # @option options [optional, Hash<Symbol>] :response see {#prepare_response}
    # @option options [optional, Array, Exception, StandardError, String] :error see {#prepare_error}
    # @option options [optional, TrueClass] :timeout if the stubbed request should raise Timeout
    #
    # @example Stub a HTTP Request with WebMock
    #   register_stub(
    #     :google_api,
    #     :get_map_location,
    #     { request: { headers: { "Accept" => "application/json" }}},
    #     { response: { body: { id: "abyasdjasd", status: "successful" }}}
    #   )
    #
    # @return [WebMock::RequestStub] a mocked request
    #
    def stub_http_request(verb, uri, options = {})
      request  = prepare_request(options[:request])
      response = prepare_response(options[:response])
      error    = prepare_error(options[:error])

      request_stub = WebMock::RequestStub.new(verb, uri)
      request_stub.with(request)       if request.present?
      request_stub.to_return(response) if response.present?
      request_stub.to_raise(*error)    if error.present?
      request_stub.to_timeout          if options[:timeout]

      WebMock::StubRegistry.instance.register_request_stub(request_stub)
    end

    #
    # Prepare request options for WebMock::RequestStub#with
    #
    # @param [Hash<Symbol>] options
    # @option options [optional, Hash<Symbol>, Hash<String>, String] :query the request query string
    # @option options [optional, Hash<String>] :headers the request headers
    # @option options [optional, Hash<Symbol>, Hash<String>, String] :body the request body
    #
    # @example Prepare a request options for webock
    #   prepare_request(
    #     {
    #       query: "key=val",
    #       headers: { "Accept" => "application/json" },
    #       body: { id: "abyasdjasd",status: "successful" }
    #     }
    #   )
    #
    # @return [Hash] a hash with the keys `:status`, `:headers` and `:body`
    #   if the keys have values, otherwise and empty hash is returned.
    #
    def prepare_request(options = {})
      return {} if options.blank?

      options.delete_if { |_k, v| v.blank? }
    end

    #
    # Prepare response options for WebMock::RequestStub#to_return
    #
    # @param [Hash<Symbol>] options
    # @option options [optional, Integer] :status the response status
    # @option options [optional, Hash<String>] :headers the response headers
    # @option options [optional, Hash<Symbol>, Hash<String>, String] :body the response body
    #
    # @example Prepare a request options for webock
    #   prepare_response(
    #     {
    #       status: 204,
    #       headers: { "Accept" => "application/json" },
    #       body: "No Content"
    #     }
    #   )
    #
    # @return [Hash] a hash with the keys `:status`, `:headers` and `:body`
    #   if the keys have values, otherwise and empty hash is returned.
    #
    def prepare_response(options = {})
      return {} if options.blank?

      options.delete_if { |_k, v| v.blank? }
    end

    #
    # Prepare an error for WebMock::RequestStub#to_raise
    #
    # @param [Array, Exception, String] error
    #
    # @example Prepare WebMock to raise an exception class
    #   prepare_error(StandardError) #=> `[StandardError]`
    #
    # @example Prepare WebMock to raise a string as an error
    #   prepare_error("A string to raise") #=> `["A string to raise"]`
    #
    # @example Prepare WebMock to raise an error with a custom message
    #   prepare_error([StandarError, "Custom error message"]) #=> `[StandarError, "Custom error message"]`
    #
    # @example Prepare WebMock to raise an instance of an exception
    #   prepare_error([Exception.new("What is going on?")]) #=> `[#<Exception: What is going on?>]`
    #
    # @return [Array] A list with an (Exception), (String) or both
    #
    def prepare_error(error)
      return Array(error) if error
    end
  end
end

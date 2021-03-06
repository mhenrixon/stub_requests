# frozen_string_literal: true

require "spec_helper"
require "net/http"
require "securerandom"

RSpec.describe "Stubs HTTP requests", record_stubs: true do # rubocop:disable RSpec/DescribeClass
  include StubRequests::API

  let(:service_id)   { :example_api }
  let(:service_uri)  { "https://example.com/api/v1" }
  let(:endpoint)     { service.register(endpoint_id, verb, path) }
  let(:endpoint_id)  { :list_task }
  let(:verb)         { :get }
  let(:path)         { "lists/:list_id/tasks/:task_id" }
  let(:list_id)      { SecureRandom.hex }
  let(:task_id)      { SecureRandom.hex }
  let(:route_params) do
    {
      list_id: list_id,
      task_id: task_id,
    }
  end
  let(:callback) { -> {} }

  let(:example_api_list_task_status) { 200 }
  let(:example_api_list_task_response) do
    {
      task_id: task_id,
      list_id: list_id,
      completed: false,
      completed_at: nil,
    }
  end

  def register_endpoints
    register_service(service_id, service_uri) do
      register(endpoint_id, verb, path)
    end
  end

  def register_callbacks
    register_callback(service_id, endpoint_id, :any, callback)
  end

  def register_stubs
    stub_endpoint(endpoint_id, route_params) do
      to_return(
        body: example_api_list_task_response.to_json,
        status: example_api_list_task_status,
      )
    end
  end

  before do
    register_endpoints
    register_callbacks
    register_stubs
  end

  it "stubs the request nicely" do
    uri = URI("https://example.com/api/v1/lists/#{list_id}/tasks/#{task_id}")
    response = Net::HTTP.get(uri)
    expect(response).to be_json_eql(example_api_list_task_response.to_json)
  end
end

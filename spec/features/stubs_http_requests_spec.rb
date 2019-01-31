# frozen_string_literal: true

require "spec_helper"
require "net/http"
require "securerandom"

RSpec.describe "Stubs HTTP requests" do # rubocop:disable RSpec/DescribeClass, RSpec/EmptyExampleGroup
  let(:api)          { StubRequests::API }
  let(:service)      { StubRequests.register_service(service_id, service_uri) }
  let(:service_id)   { :example_api }
  let(:service_uri)  { "https://example.com/api/v1" }
  let(:endpoint)     { service.register_endpoint(endpoint_id, verb, uri_template) }
  let(:endpoint_id)  { :list_task }
  let(:verb)         { :get }
  let(:uri_template) { "lists/:list_id/tasks/:task_id" }
  let(:list_id)      { SecureRandom.hex }
  let(:task_id)      { SecureRandom.hex }

  let(:uri_replacements) do
    {
      list_id: list_id,
      task_id: task_id,
    }
  end

  let(:example_api_list_task_status) { 200 }
  let(:example_api_list_task_response) do
    {
      task_id: task_id,
      list_id: list_id,
      completed: false,
      completed_at: nil,
    }
  end

  before do
    endpoint

    api.stub_endpoint(service_id, endpoint_id, uri_replacements) do |request|
      request.to_return(
        body: example_api_list_task_response.to_json,
        status: example_api_list_task_status,
      )
    end
  end

  it "nicely stubs the request" do
    uri = URI("https://example.com/api/v1/lists/#{list_id}/tasks/#{task_id}")
    response = Net::HTTP.get(uri)
    expect(response).to be_json_eql(example_api_list_task_response.to_json)
  end
end

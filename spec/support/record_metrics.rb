# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :record_stubs) do |example|
    record_stubs_was = StubRequests.config.record_stubs
    StubRequests.config.record_stubs = example.metadata[:record_stubs]
    example.run
    StubRequests.config.record_stubs = record_stubs_was
  end
end

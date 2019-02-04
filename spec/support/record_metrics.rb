# frozen_string_literal: true

RSpec.configure do |config|
  config.around(:each, :record_metrics) do |example|
    record_metrics_was = StubRequests.config.record_metrics
    StubRequests.config.record_metrics = example.metadata[:record_metrics]
    example.run
    StubRequests.config.record_metrics = record_metrics_was
  end
end

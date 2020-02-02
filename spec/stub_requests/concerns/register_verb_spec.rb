# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Concerns::RegisterVerb do
  before do
    registrator_class = Class.new do
      include StubRequests::Concerns::RegisterVerb
    end

    stub_const("Registrator", registrator_class)
  end
end

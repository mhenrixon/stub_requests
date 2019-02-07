# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::Concerns::RegisterVerb do
  class Registrator
    include StubRequests::Concerns::RegisterVerb
  end
end

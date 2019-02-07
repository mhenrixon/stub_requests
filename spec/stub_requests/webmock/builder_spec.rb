# frozen_string_literal: true

require "spec_helper"

RSpec.describe StubRequests::WebMock::Builder do
  let(:builder)          { described_class.new(verb, uri) }
  let(:verb)             { :get }
  let(:uri)              { "http://service-less:9292/internal/accounts/acoolaccountuid" }

  describe "#build" do
    subject(:build) { builder.build }

    it { is_expected.to be_a(WebMock::RequestStub) }

    describe "configuration of WebMock::RequestStub" do
      let(:request_stub) { WebMock::RequestStub.new(verb, uri) }

      before do
        allow(WebMock::RequestStub).to receive(:new).with(verb, uri).and_return(request_stub)
        allow(request_stub).to receive(:with)
        allow(request_stub).to receive(:to_return)
        allow(request_stub).to receive(:to_raise)
        allow(request_stub).to receive(:to_timeout)

        build
      end

      it { is_expected.to be_a(WebMock::RequestStub) }
    end
  end
end

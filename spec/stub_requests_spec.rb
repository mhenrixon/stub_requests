# frozen_string_literal: true

RSpec.describe StubRequests do
  subject { described_class }

  it "has a version number" do
    expect(StubRequests::VERSION).not_to be nil
  end

  it { is_expected.to respond_to(:logger) }
  it { is_expected.to respond_to(:logger=) }
  it { is_expected.to respond_to(:version) }

  describe ".version" do
    subject(:version) { described_class.version }

    it { is_expected.to eq(described_class::VERSION) }
  end

  describe ".logger=" do
    subject(:set_logger) { described_class.logger = logger }

    let(:logger)  { Logger.new(STDOUT) }
    let!(:logwas) { described_class.logger }

    after do
      described_class.logger = logwas
    end

    it "changes the logger" do
      expect { set_logger }
        .to change { described_class.logger }
        .from(logwas)
        .to(logger)
    end
  end
end

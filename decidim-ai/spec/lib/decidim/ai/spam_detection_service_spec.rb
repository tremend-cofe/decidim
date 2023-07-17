# frozen_string_literal: true

require "spec_helper"

describe Decidim::Ai::SpamDetectionService do
  subject { described_class.new }

  let(:registry) { Decidim::Ai.spam_detection_registry }
  let(:base_strategy) { { name: :base, strategy: Decidim::Ai::SpamContent::BaseStrategy } }
  let(:dummy_strategy) { { name: :dummy, strategy: Decidim::Ai::SpamContent::BaseStrategy } }

  before do
    registry.clear
    registry.register_analyzer(**base_strategy)
    registry.register_analyzer(**dummy_strategy)
  end

  describe "train" do
    it "trains all the strategies" do
      expect(registry.for(:base)).to receive(:train).with(:spam, "text")
      expect(registry.for(:dummy)).to receive(:train).with(:spam, "text")

      subject.train(:spam, "text")
    end
  end

  describe "untrain" do
    it "untrains all the strategies" do
      expect(registry.for(:base)).to receive(:untrain).with(:spam, "text")
      expect(registry.for(:dummy)).to receive(:untrain).with(:spam, "text")

      subject.untrain(:spam, "text")
    end
  end

  describe "classify" do
    it "classifies using all strategies" do
      expect(registry.for(:base)).to receive(:untrain).with(:spam, "text")
      expect(registry.for(:dummy)).to receive(:untrain).with(:spam, "text")

      subject.classify("text")
    end
  end

  describe "classification_log" do
    it "returns the log of all strategies" do
      allow(registry.for(:base)).to receive(:log).and_return("base log")
      allow(registry.for(:dummy)).to receive(:log).and_return("dummy log")

      expect(subject.classification_log).to eq("base log\ndummy log")
    end
  end
end

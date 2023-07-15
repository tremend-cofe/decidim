# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tools
    module Ai
      module SpamContent
        describe Classifier do
          subject { described_class.new(organization) }

          let(:organization) { create(:organization) }
          let(:locale) { "en" }

          let!(:admin) { create(:user, :admin, :confirmed, organization:, about: "Administrator account of this Decdidim instance should be a developer") }
          let!(:good_user) { create(:user, organization:, about: "I am Groot! I am a movie Character") }
          let!(:blocked_user) { create(:user, :blocked, organization:, about: "Click here to win a very interesting prize") }
          let(:moderation) { create(:user_moderation, user: blocked_user, report_count: 1) }
          let!(:report) { create(:user_report, moderation:, user: blocked_user, reason: "spam") }

          before do
            Decidim::Tools::Ai.backend = :memory
            Decidim::Tools::Ai.load_vendor_data = false
            Decidim::Tools::Ai.trained_models = %w(Decidim::Tools::Ai::Resource::UserBaseEntity)

            Decidim::Tools::Ai::SpamContent::Repository.train!
          end

          describe "compute_classification_score" do
            it "marks as spam" do
              subject.classify!("You are the lucky winner! Claim your holiday prize.", locale)
              expect(subject.score).to eq(0.25) # Bayes score is -30.092211239099232
            end

            it "does not mark as spam" do
              subject.classify!("I am a passionate Decidim developer.", locale)
              expect(subject.score).to eq(0) # Bayes score is -16.10211869643518
            end
          end

          describe "compute_language_scope" do
            it "does not mark as spam" do
              subject.classify!("I am a passionate Decidim developer.", locale)
              expect(subject.score).to eq(0) # Bayes score is -16.10211869643518
            end

            it "marks as spam" do
              subject.classify!("Esti castigatorul al unei excursii", locale)
              expect(subject.score).to eq(0.5)
            end
          end

          describe "compute_forbidden_words" do
            let!(:keyword) { create(:forbidden_word, word: "winner", organization:) }

            it "does not mark as spam" do
              subject.classify!("I am a passionate Decidim developer.", locale)
              expect(subject.score).to eq(0) # Bayes score is -16.10211869643518
            end

            it "marks as spam" do
              subject.classify!("You are the lucky winner! Claim your holiday prize.", locale)
              expect(subject.score).to eq(0.5)
            end
          end
        end
      end
    end
  end
end

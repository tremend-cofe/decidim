

# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Forms
    describe Questionnaire do
      subject { questionnaire }

      describe "#answered_by?" do
        let(:component) { create(:component, manifest_name: "surveys") }
        let!(:survey) { create(:survey, component: ) }
        let!(:questionnaire) { create(:questionnaire, :with_questions, questionnaire_for: survey) }
        let!(:question) { create(:questionnaire_question, questionnaire:) }
        let!(:user) { create(:user, organization: component.participatory_space.organization) }

        it "returns false if the given user has not answered the questionnaire" do
          expect(questionnaire).not_to be_answered_by(user)
        end

        it "returns true if the given user has answered the questionnaire" do
          create(:answer, questionnaire:, question:, user:)
          expect(questionnaire).to be_answered_by(user)
        end

        context "when global settings of component allows multiple answers" do
          let!(:answer) { create(:answer, questionnaire:, question:, user:) }

          it "returns true if the the setting is disabled" do
            component.update!(settings: { allow_multiple_answers: false })
            expect(questionnaire).to be_answered_by(user)
          end

          it "returns false if the setting is disabled" do
            component.update!(settings: { allow_multiple_answers: true })
            expect(questionnaire).not_to be_answered_by(user)
          end
        end

        context "when global settings of component allows multiple answers" do
          let!(:answer) { create(:answer, questionnaire:, question:, user:) }
          
          it "returns true if the the setting is disabled" do
            component.update!(settings: { allow_multiple_answers: false })
            expect(questionnaire).to be_answered_by(user)
          end

          it "returns false if the setting is disabled" do
            component.update!(settings: { allow_multiple_answers: true })
            expect(questionnaire).not_to be_answered_by(user)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyType < Types::BaseObject
      description "A survey"

      field :id, ID, "The internal ID for this survey", null: false
      field :created_at, Decidim::Core::DateTimeType, "The time this survey was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "The time this survey was updated", null: true
      field :questionnaire, Decidim::Forms::QuestionnaireType, "The questionnaire for this survey", null: true
    end
  end
end

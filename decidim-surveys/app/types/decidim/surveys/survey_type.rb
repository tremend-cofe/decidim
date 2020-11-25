# frozen_string_literal: true

module Decidim
  module Surveys
    class SurveyType < Decidim::Api::Types::BaseObject
      description "A survey"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, "The internal ID for this survey", null: false
      field :questionnaire, Decidim::Forms::QuestionnaireType, "The questionnaire for this survey", null: true
    end
  end
end

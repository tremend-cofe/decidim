# frozen_string_literal: true

module Decidim
  module Forms
    class QuestionType < Decidim::Api::Types::BaseObject
      description "A question in a questionnaire"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, "ID of this question", null: false
      field :body, Decidim::Core::TranslatedFieldInterface, "What is being asked in this question.", null: false
      field :description, Decidim::Core::TranslatedFieldInterface, "The description of this question.", null: true
      field :mandatory, Boolean, "Whether if this question is mandatory.", null: false
      field :position, Int, "Order position of the question in the questionnaire", null: true
      field :max_choices, Int, "On questions with answer options, maximum number of choices the user has", null: true
      field :question_type, String, "Type of question.", null: true
      field :answer_options, [AnswerOptionType, null: true], "List of answer options in multi-choice questions.", null: false
    end
  end
end

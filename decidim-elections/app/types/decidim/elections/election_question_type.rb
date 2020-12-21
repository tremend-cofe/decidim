# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an election Question.
    # The name is different from the model because the Question type is already defined on the Forms module.
    class ElectionQuestionType < Decidim::Api::Types::BaseObject

      implements  Decidim::Core::TraceableInterface

      description "A question for an election"

      field :id, ID, "The internal ID of this question", null: false
      field :title, Decidim::Core::TranslatedFieldType, "The title for this question", null: false
      field :description, Decidim::Core::TranslatedFieldType, "The description for this question", null: false
      field :max_selections, Integer, "The maximum number of possible selections for this question", null: false
      field :weight, Integer, "The ordering weight for this question", null: true
      field :random_answers_order, Boolean, "Should this question order answers in random order?", null: true
      field :min_selections, Integer, "The minimum number of possible selections for this question", null: false
      field :answers, [Decidim::Elections::ElectionAnswerType, null: true], "The answers for this question", null: false
    end
  end
end

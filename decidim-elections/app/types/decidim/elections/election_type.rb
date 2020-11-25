# frozen_string_literal: true

module Decidim
  module Elections
    # This type represents an Election.
    class ElectionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::AttachableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      description "An election"

      field :id, ID, "The internal ID of this election", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for this election", null: false
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this election", null: false
      field :start_time, Decidim::Core::DateTimeType, "The start time for this election", null: false
      field :end_time, Decidim::Core::DateTimeType, "The end time for this election", null: false
      field :published_at, Decidim::Core::DateTimeType, "When this election was published", null: true
      field :blocked, Boolean, "Whether this election has it's parameters blocked or not", method: :blocked?, null: true
      field :bb_status, String, "The status for this election in the bulletin board", null: true

      field :questions, [Decidim::Elections::ElectionQuestionType, null: true], "The questions for this election", null: false
      field :trustees, [Decidim::Elections::TrusteeType, null: true], "The trustees for this election", null: false
    end
  end
end

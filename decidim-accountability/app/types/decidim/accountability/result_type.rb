# frozen_string_literal: true

module Decidim
  module Accountability
    class ResultType < Decidim::Api::Types::BaseObject
      description "A result"

      implements Decidim::Core::ComponentInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TimestampsInterface

      field :id, ID, "The internal ID for this result", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for this result", null: true
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this result", null: true
      field :reference, String, "The reference for this result", null: true
      field :start_date, Decidim::Core::DateType, "The start date for this result", null: true
      field :end_date, Decidim::Core::DateType, "The end date for this result", null: true
      field :progress, Float, "The progress for this result", null: true
      field :children_count, Int, "The number of children results", null: true
      field :weight, Int, "The order of this result", null: false
      field :external_id, String, "The external ID for this result", null: true

      field :children, [Decidim::Accountability::ResultType, null: true], "The childrens results", null: true
      field :parent, Decidim::Accountability::ResultType, "The parent result", null: true
      field :status, Decidim::Accountability::StatusType, "The status for this result", null: true
      field :timeline_entries, [Decidim::Accountability::TimelineEntryType, null: true], "The timeline entries for this result", null: true
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Debates
    class DebateType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Core::TranslatedFieldInterface

      description "A debate"

      field :id, ID, "The internal ID for this debate", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for this debate", null: true
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this debate", null: true
      field :instructions, Decidim::Core::TranslatedFieldInterface, "The instructions for this debate", null: true
      field :start_time, Decidim::Core::DateTimeType, "The start time for this debate", null: true
      field :end_time, Decidim::Core::DateTimeType, "The end time for this debate", null: true
      field :image, String, "The image of this debate", null: true
      field :information_updates, Decidim::Core::TranslatedFieldType, "The information updates for this debate", null: true
      field :reference, String, "The reference for this debate", null: true
    end
  end
end

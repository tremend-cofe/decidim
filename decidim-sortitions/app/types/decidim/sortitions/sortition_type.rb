# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::AuthorableInterface
      implements Decidim::Comments::CommentableInterface
      implements Decidim::Core::CategorizableInterface
      implements Decidim::Core::TimestampsInterface
      description "A sortition"

      field :id, ID, "The internal ID for this sortition", null: false
      field :dice, Int, "The dice for this sortition", null: true
      field :target_items, Int, "The target items for this sortition", null: true
      field :request_timestamp, Decidim::Core::DateType, "The request time stamp for this request", null: true
      field :selected_proposals, [Int, null: true], "The selected proposals for this sortition", null: true
      field :witnesses, Decidim::Core::TranslatedFieldInterface, "The witnesses for this sortition", null: true
      field :additional_info, Decidim::Core::TranslatedFieldInterface, "The additional info for this sortition", null: true
      field :reference, String, "The reference for this sortition", null: true
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for this sortition", null: true
      field :cancel_reason, Decidim::Core::TranslatedFieldInterface, "The cancel reason for this sortition", null: true
      field :cancelled_on, Decidim::Core::DateType, "When this sortition was cancelled", null: true
      field :cancelled_by_user, Decidim::Core::UserInterface, "Who cancelled this sortition", null: true
      field :candidate_proposals, Decidim::Core::TranslatedFieldInterface, "The candidate proposal for this sortition", null: true
    end
  end
end

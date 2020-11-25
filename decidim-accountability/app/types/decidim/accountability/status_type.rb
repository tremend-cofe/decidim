# frozen_string_literal: true

module Decidim
  module Accountability
    class StatusType < Decidim::Api::Types::BaseObject
      description "A status"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, "The internal ID for this status", null: false
      field :key, String, "The key for this status", null: true
      field :name, Decidim::Core::TranslatedFieldInterface, "The name for this status", null: true
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this status", null: true
      field :progress, Int, "The progress for this status", null: true

      field :results, [Decidim::Accountability::ResultType, null: true], "The results for this status", null: true
    end
  end
end

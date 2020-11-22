# frozen_string_literal: true

module Decidim
  module Accountability
    class TimelineEntryType < Types::BaseObject
      description "A Timeline Entry"

      field :id, ID, "The internal ID for this timeline entry", null: false
      field :entry_date, Decidim::Core::DateType, "The entry date for this timeline entry", null: true
      field :description, Decidim::Core::TranslatedFieldType, "The description for this timeline entry", null: true
      field :created_at, Decidim::Core::DateTimeType, "When this timeline entry was created", null: true
      field :updated_at, Decidim::Core::DateTimeType, "When this timeline entry was updated", null: true

      field :result, Decidim::Accountability::ResultType, "The result for this timeline entry", null: true
    end
  end
end

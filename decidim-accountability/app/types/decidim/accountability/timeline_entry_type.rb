# frozen_string_literal: true

module Decidim
  module Accountability
    class TimelineEntryType < Decidim::Api::Types::BaseObject
      description "A Timeline Entry"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, "The internal ID for this timeline entry", null: false
      field :entry_date, Decidim::Core::DateType, "The entry date for this timeline entry", null: true
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this timeline entry", null: true

      field :result, Decidim::Accountability::ResultType, "The result for this timeline entry", null: true
    end
  end
end

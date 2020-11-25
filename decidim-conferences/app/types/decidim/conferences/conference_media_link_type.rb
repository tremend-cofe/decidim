# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceMediaLinkType < Decidim::Api::Types::BaseObject
      description "A conference media link"

      implements Decidim::Core::TimestampsInterface

      field :id, ID, "Internal ID for this media link", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "Title for this media link", null: true
      field :link, String, "URL for this media link", null: true
      field :date, Decidim::Core::DateType, "Relevant date for the media link", null: true
      field :weight, Int, "Order of appearance in which it should be presented", null: true
    end
  end
end

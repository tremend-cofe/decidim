# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferenceSpeakerType < Decidim::Api::Types::BaseObject
      description "A conference speaker"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, "Internal ID of the speaker", null: false
      field :full_name, String, "Full name of the speaker", null: true
      field :position, Decidim::Core::TranslatedFieldInterface, "Position of the speaker in the conference", null: true
      field :affiliation, Decidim::Core::TranslatedFieldInterface, "Affiliation of the speaker", null: true
      field :twitter_handle, String, "Twitter handle", null: true
      field :short_bio, Decidim::Core::TranslatedFieldInterface, "Short biography of the speaker", null: true
      field :personal_url, String, "Personal URL of the speaker", null: true
      field :avatar, String, "Avatar of the speaker", null: true
      field :user, Decidim::Core::UserInterface, "Decidim user corresponding to this speaker", null: true
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Meetings
    class MinutesType < Decidim::Api::Types::BaseObject
      graphql_name "MeetingMinutes"
      description "A meeting minutes"

      field :id, ID, "The ID for the minutes", null: false
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for the minutes", null: true
      field :video_url, String, "URL for the video of the session, if any", null: true
      field :audio_url, String, "URL for the audio of the session, if any", null: true
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible
      implements Decidim::Core::TimestampsInterface

    end
  end
end

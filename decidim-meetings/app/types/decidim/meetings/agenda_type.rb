# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaType < Decidim::Api::Types::BaseObject
      graphql_name "MeetingAgenda"
      description "A meeting agenda"

      field :id, ID, "The ID for the agenda", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for the agenda", null: true
      field :items, [AgendaItemType, null: true], "Items and sub-items of the agenda", method: :agenda_items, null: false
      # probably useful in the future, when handling user permissions
      # field :visible, !types.Boolean, "Whether this minutes is public or not", property: :visible

      implements Decidim::Core::TimestampsInterface

    end
  end
end

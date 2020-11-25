# frozen_string_literal: true

module Decidim
  module Meetings
    class AgendaItemType < Decidim::Api::Types::BaseObject
      graphql_name "MeetingAgendaItem"
      description "A meeting agenda item"

      field :id, ID, "The ID for this agenda item", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for this agenda item", null: true
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this agenda item", null: true
      field :items, [AgendaItemType, null: true], "Sub-items (children) of this agenda item", method: :agenda_item_children, null: false
      field :parent, AgendaItemType, "Parent agenda item, if available", null: true
      field :agenda, AgendaType, "Belonging agenda", null: true
      field :duration, Int, "Duration in number of minutes for this item in this agenda", null: false
      field :position, Int, "Order position for this agenda item", null: false

      implements Decidim::Core::TimestampsInterface
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Conferences
    # This type represents a conference.
    class ConferencePartnerType < Decidim::Api::Types::BaseObject
      description "A conference partner"
      implements Decidim::Core::TimestampsInterface

      field :id, ID, "ID of the resource", null: false
      field :name, String, "Partner name", null: true
      field :partner_type, String, "Partner type", null: true
      field :weight, Int, "Order of appearance in which it should be presented", null: true
      field :link, String, "Relevant URL for this partner", null: true
      field :logo, String, "Link to the partner's logo", null: true
    end
  end
end

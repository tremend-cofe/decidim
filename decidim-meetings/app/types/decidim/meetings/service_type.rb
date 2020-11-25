# frozen_string_literal: true

module Decidim
  module Meetings
    class ServiceType < Decidim::Api::Types::BaseObject
      graphql_name "MeetingService"
      description "A meeting service"

      field :title, Decidim::Core::TranslatedFieldInterface, "The title for the service", null: true
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for the service", null: true
    end
  end
end

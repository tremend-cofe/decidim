# frozen_string_literal: true

module Decidim
  module Core
    class AreaApiType < Decidim::Api::Types::BaseObject
      graphql_name "Area"
      description "An area."
      implements TimestampsInterface

      field :id, ID, "Internal ID for this area", null: false
      field :name, Decidim::Core::TranslatedFieldInterface, "The name of this area.", null: false
      field :area_type, Decidim::Core::AreaTypeType, "The area type of this area", null: true
    end
  end
end

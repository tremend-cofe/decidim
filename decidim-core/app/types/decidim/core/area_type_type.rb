# frozen_string_literal: true

module Decidim
  module Core
    class AreaTypeType < Types::BaseObject
      description "An area type."

      field :id, ID, "Internal ID for this area type", null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this area type.", null: false
      field :plural, Decidim::Core::TranslatedFieldType, "The plural name of this area type", null: false
    end
  end
end

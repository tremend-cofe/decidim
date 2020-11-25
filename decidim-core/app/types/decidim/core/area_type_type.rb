# frozen_string_literal: true

module Decidim
  module Core
    class AreaTypeType < Decidim::Api::Types::BaseObject
      description "An area type."

      field :id, ID, "Internal ID for this area type", null: false
      field :name, Decidim::Core::TranslatedFieldInterface, "The name of this area type.", null: false
      field :plural, Decidim::Core::TranslatedFieldInterface, "The plural name of this area type", null: false
    end
  end
end

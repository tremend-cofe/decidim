# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a localized string in a single language.
    class LocalizedStringType < Types::BaseObject
      graphql_name "Localized"
      description "Represents a particular translation of a LocalizedStringType"

      field :locale, String, "The standard locale of this translation.", null: false
      field :text, String, "The content of this translation.", null: true
    end
  end
end

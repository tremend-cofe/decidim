# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a translated field in multiple languages.
    class TranslatedFieldType < Types::BaseObject
      graphql_name  "TranslatedField"
      description "A translated field"

      field :locales, [String, null: true], description: "Lists all the locales in which this translation is available", null: true

      def locales
        object.keys
      end

      field :translations, [LocalizedStringType, null: true], null: false do
        description "All the localized strings for this translation."

        argument :locales, [String], description: "A list of locales to scope the translations to.", required: false

        def resolve_field(obj, args, _ctx)
          translations = obj.stringify_keys
          translations = translations.slice(*args["locales"]) if args["locales"]

          translations.map { |locale, text| OpenStruct.new(locale: locale, text: text) }
        end
      end

      field :translation, String, description: "Returns a single translation given a locale.", null: true do
        argument :locale, String, "A locale to search for", required: true

        def resolve_field(obj, args, _ctx)
          translations = obj.stringify_keys
          translations[args["locale"]]
        end
      end
    end
  end
end

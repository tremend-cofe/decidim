# frozen_string_literal: true

module Decidim
  module Core
    # This type represents a Decidim's global property.
    class DecidimType < Types::BaseObject
      description "Decidim's framework-related properties."

      field :version, String, "The current decidim's version of this deployment.", null: false

      def version
        object.version
      end

      field :application_name, String, "The current installation's name.", null: false

      def application_name
        object.application_name
      end
    end
  end
end

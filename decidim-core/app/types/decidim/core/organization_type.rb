# frozen_string_literal: true

module Decidim
  module Core
    class OrganizationType < Types::BaseObject
      description "The current organization"

      field :name, String, "The name of the current organization", null: true

      field :stats, [Core::StatisticType, null: true], description: "The statistics associated to this object", null: true

      def stats
        Decidim.stats.with_context(object)
      end
    end
  end
end

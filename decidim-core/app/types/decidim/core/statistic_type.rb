# frozen_string_literal: true

module Decidim
  module Core
    class StatisticType < Decidim::Api::Types::BaseObject
      description "Represents a single statistic"

      field :name, String, "The name of the statistic", null: false

      def name
        object[0]
      end

      field :value, Int, "The actual value of the statistic", null: false

      def value
        object[1]
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Budgets
    class BudgetType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ScopableInterface
      implements Decidim::Core::TraceableInterface
      implements Decidim::Core::TimestampsInterface

      description "A budget"

      field :id, ID, "The internal ID of this budget", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title for this budget", null: false
      field :description, Decidim::Core::TranslatedFieldInterface, "The description for this budget", null: false
      field :total_budget, Int, "The total budget", null: false

      field :projects, [Decidim::Budgets::ProjectType, null: true], "The projects for this budget", null: false
    end
  end
end

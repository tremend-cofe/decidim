# frozen_string_literal: true

module Decidim
  module Core
    class CategoryType < Types::BaseObject
      description "A category that can be applied to other resources."

      field :id, ID, null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this category.", null: false

      field :subcategories, [Decidim::Core::CategoryType, null: true], "Subcategories of this category.", null: false
      field :parent, Decidim::Core::CategoryType, "This category's parent category.", null: true
    end
  end
end

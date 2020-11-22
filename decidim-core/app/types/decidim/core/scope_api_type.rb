# frozen_string_literal: true

module Decidim
  module Core
    class ScopeApiType < Types::BaseObject
      graphql_name "Scope"
      description "A scope"

      field :id, ID, null: false
      field :name, Decidim::Core::TranslatedFieldType, "The name of this scope.", null: false

      field :children, [Decidim::Core::ScopeApiType, null: true], "Descendants of this scope", null: false
      field :parent, Decidim::Core::ScopeApiType, "This scope's parent scope.", null: true
    end
  end
end

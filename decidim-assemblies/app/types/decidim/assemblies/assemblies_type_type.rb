# frozen_string_literal: true

module Decidim
  module Assemblies
    # This type represents an AssembliesType.
    class AssembliesTypeType < Decidim::Api::Types::BaseObject
      description "An assemblies type"
      implements Decidim::Core::TimestampsInterface

      field :id, GraphQL::Types::ID, "The assemblies type's unique ID", null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title of this assemblies type.", null: false
      field :assemblies, [Decidim::Assemblies::AssemblyType, null: true], "Assemblies with this assemblies type", null: false
    end
  end
end

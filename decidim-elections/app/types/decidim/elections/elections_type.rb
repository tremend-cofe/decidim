# frozen_string_literal: true

module Decidim
  module Elections
    class ElectionsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Elections"
      description "An elections component of a participatory space."

      field :elections, ElectionType.connection_type, null: true, connection: true

      def elections
        Election.where(component: object).where.not(published_at: nil).includes(:component)
      end

      field :election, ElectionType, null: true do
        argument :id, ID, required: true
      end

      def election(**args)
        Election.where(component: object).where.not(published_at: nil).find_by(id: args[:id])
      end
    end
  end
end

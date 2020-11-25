# frozen_string_literal: true

module Decidim
  module Sortitions
    class SortitionsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Sortitions"
      description "A sortition component of a participatory space."

      field :sortitions, SortitionType.connection_type, null: true, connection: true

      def sortitions
        Sortition.where(component: object).includes(:component)
      end

      field :sortition, SortitionType, null: true do
        argument :id, ID, required: true
      end

      def sortition(**args)
        Sortition.where(component: object).find_by(id: args[:id])
      end
    end
  end
end

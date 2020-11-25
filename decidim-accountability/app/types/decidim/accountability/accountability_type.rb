# frozen_string_literal: true

module Decidim
  module Accountability
    class AccountabilityType < Decidim::Api::Types::BaseObject
      graphql_name "Accountability"
      description "An accountability component of a participatory space."

      implements Decidim::Core::ComponentInterface

      field :results, ResultType.connection_type, null: true, connection: true

      def results
        Result.where(component: object).includes(:component)
      end

      field :result, ResultType, null: true do
        argument :id, ID, required: true
      end

      def result(**args)
        Result.where(component: object).find_by(id: args[:id])
      end
    end
  end
end

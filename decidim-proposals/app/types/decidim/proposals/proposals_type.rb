# frozen_string_literal: true

module Decidim
  module Proposals

    class ProposalListHelper < Decidim::Core::ComponentListBase
      # only querying published posts
      def query_scope
        super.published
      end
    end

    class ProposalFinderHelper < Decidim::Core::ComponentFinderBase
      def query_scope
        super.published
      end
    end

    class ProposalsType < Decidim::Api::Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Proposals"
      description "A proposals component of a participatory space."

      field :proposals, type: ProposalType.connection_type, description: "List all proposals", null: true, connection: true  do
        argument :order, ProposalInputSort, "Provides several methods to order the results", required: false
        argument :filter, ProposalInputFilter, "Provides several methods to filter the results", required: false
        def resolve_field(object:, args:, context: )
          Decidim::Proposals::ProposalListHelper.new(model_class: Proposal).call(component, args, context)
        end
      end

      field :proposal, type: ProposalType, description: "Finds one proposal", null: true do
        argument :id, GraphQL::Types::ID, "The ID of the proposal", required: true

        def resolve_field(object:, args:, context: )
          Decidim::Proposals::ProposalFinderHelper.new(model_class: Proposal).call(component, args, context)
        end
      end
    end

  end
end

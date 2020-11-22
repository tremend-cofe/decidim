# frozen_string_literal: true

module Decidim
  module ParticipatoryProcesses
    # This module's job is to extend the API with custom fields related to
    # decidim-participatory_processes.
    module QueryExtensions
      # Public: Extends a type with `decidim-participatory_processes`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(type)
        type.field :participatory_process_groups, [ParticipatoryProcessGroupType, null: true], description: "Lists all participatory process groups", null: false

        def participatory_process_groups
          Decidim::ParticipatoryProcessGroup.where(organization: context[:current_organization])
        end

        type.field :participatory_process_group, ParticipatoryProcessGroupType, description: "Finds a participatory process group", null: true do
          argument :id, GraphQL::Types::ID, "The ID of the Participatory process group", required: true
          def resolve_field(object:, args:, context:)
            Decidim::ParticipatoryProcessGroup.find_by(
              organization: ctx[:current_organization],
              id: args[:id]
            )
          end
        end
      end
    end
  end
end

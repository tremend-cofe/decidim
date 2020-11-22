# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a participatorySpaceResourceable object.
    # It create and array of linked participatory spaces for each registered manifest
    #

    module ParticipatorySpaceResourceableInterface
      include Types::BaseInterface
      graphql_name  "ParticipatorySpaceResourcableInterface"
      description "An interface that can be used in objects with participatorySpaceResourceable"

      field "linkedParticipatorySpaces", [ParticipatorySpaceLinkType], null: true, description: "Lists all linked participatory spaces in a polymorphic way" do
        def resolve_field(participatory_space, _args, _ctx)
          Decidim::ParticipatorySpaceLink.where("name like 'included_%' and ((from_id=:id and from_type=:type) or (to_id=:id and to_type=:type))",
                                                id: participatory_space.id, type: participatory_space.class.name)
        end
      end
    end
  end
end

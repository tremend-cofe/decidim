# frozen_string_literal: true

module Decidim
  module Initiatives
    # This interface represents a commentable object.
    module InitiativeTypeInterface
      include Types::BaseInterface
      description "An interface that can be used in Initiative objects."

      field :initiative_type, Decidim::Initiatives::InitiativeApiType, "The object's initiative type", method: :type, null: true
    end
  end
end

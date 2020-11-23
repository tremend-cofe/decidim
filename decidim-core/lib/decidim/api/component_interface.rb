# frozen_string_literal: true

module Decidim
  module Core
    module ComponentInterface
      include Decidim::Api::Types::BaseInterface
      description "This interface is implemented by all components that belong into a Participatory Space"

      field :id, ID, "The Component's unique ID", null: false

      field :name, Decidim::Core::TranslatedFieldType, "The name of this component.", null: false

      field :weight, Int, "The weight of the component", null: false

      field :participatory_space, ParticipatorySpaceType, "The participatory space in which this component belongs to.", null: false

      def self.resolve_type(obj, _ctx)
        obj.manifest.query_type.constantize
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a categorizable object.
    module CategorizableInterface
      include Types::BaseInterface
      description "An interface that can be used in categorizable objects."

      field :category, Decidim::Core::CategoryType, "The object's category", null: false

    end
  end
end

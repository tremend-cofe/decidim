# frozen_string_literal: true

module Decidim
  module Pages
    class PageType < Decidim::Api::Types::BaseObject
      graphql_name "Page"
      description "A page"

      field :id, ID, null: false
      field :title, Decidim::Core::TranslatedFieldInterface, "The title of this page (same as the component name).", null: false
      field :body, Decidim::Core::TranslatedFieldInterface, "The body of this page.", null: true

      implements Decidim::Core::TimestampsInterface
    end
  end
end

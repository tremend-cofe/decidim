# frozen_string_literal: true

module Decidim
  module Api
    # This type represents the root query type of the whole API.
    class QueryType < Types::BaseObject
      description "The root query of this schema"

      Decidim::Api.query_extensions.each do |type|
        include type
      end
    end
  end
end

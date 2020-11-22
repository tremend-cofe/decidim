# frozen_string_literal: true

module Decidim
  module Blogs
    class BlogsType < Types::BaseObject
      implements Decidim::Core::ComponentInterface

      graphql_name "Blogs"
      description "A blogs component of a participatory space."

      field :posts, type: PostType.connection_type, null: true, description: "List all posts", connection: true do
        argument :order, PostInputSort, "Provides several methods to order the results", required: false
        argument :filter, PostInputFilter, "Provides several methods to filter the results", required: false
        def resolve_field(component:, args: , context: )
          Decidim::Core::ComponentListBase.new(model_class: Post).call(component, args, context)
        end
      end

      field :post, type: PostType, null: true, description: "Finds one post" do
        argument :id, ID, "The ID of the post", required: true

        def resolve_field(component:, args:, context:)
          Decidim::Core::ComponentFinderBase.new(model_class: Post).call(component, args, context)
        end
      end
    end
  end
end

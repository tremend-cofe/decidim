# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a mutation to create new comments.
    class AddCommentType < Types::BaseObject
      graphql_name "Add comment"
      description "Add a new comment"

      field :comment, CommentType, "The new created comment", null: true
    end
  end
end

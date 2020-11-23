# frozen_string_literal: true

module Decidim
  module Comments
    # This interface represents a commentable object.
    module CommentableInterface
      include Decidim::Api::Types::BaseInterface
      graphql_name "CommentableInterface"
      description "A commentable interface"

      field :id, ID, "The commentable's ID", null: false

      field :type, String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`", method: :commentable_type, null: false

      field :accepts_new_comments, Boolean, "Whether the object can have new comments or not", method: :accepts_new_comments?, null: false

      field :comments_have_alignment, Boolean, "Whether the object comments have alignment or not", method: :comments_have_alignment?, null: false

      field :comments_have_votes, Boolean, "Whether the object comments have votes or not", method: :comments_have_votes?, null: false

      field :comments, [CommentType], null: false do
        argument :order_by, String, "Order the comments", required: false
        argument :single_comment_id, String, "ID of the single comment to look at", required: false

        def resolve_field(obj:, args:, context:)
          SortedComments.for(obj, order_by: args[:orderBy], id: args[:singleCommentId])
        end
      end

      field :total_comments_count, Int, description: "The number of comments in all levels this resource holds", null: false do
        def resolve_field(obj:, args:, context:)
          obj.comments_count
        end
      end

      field :has_comments, Boolean, "Check if the commentable has comments", null: false do
        def resolve_field(obj:, args:, context:)
          obj.comment_threads.size.positive?
        end
      end

      field :user_allowed_to_comment, Boolean, "Check if the current user can comment", null: false do
        def resolve_field(obj:, args:, context:)
          obj.commentable? && obj.user_allowed_to_comment?(ctx[:current_user])
        end
      end
    end
  end
end

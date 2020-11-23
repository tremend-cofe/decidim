# frozen_string_literal: true

module Decidim
  module Comments
    # This type represents a comment on a commentable object.
    class CommentType < Decidim::Api::Types::BaseObject
      description "A comment"

      implements Decidim::Comments::CommentableInterface

      field :author, Decidim::Core::AuthorInterface, "The resource author", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.user_group || obj.author
        end
      end

      field :id, ID, "The Comment's unique ID", null: false

      field :sgid, String, "The Comment's signed global id", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.to_sgid.to_s
        end
      end

      field :body, String, "The comment message", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.translated_body
        end
      end

      field :formatted_body, String, "The comment message ready to display (it is expected to include HTML)", null: false

      field :created_at, String, "The creation date of the comment", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.created_at.iso8601
        end
      end

      field :formatted_created_at, String, "The creation date of the comment in relative format", method: :friendly_created_at, null: false

      field :alignment, Int, "The comment's alignment. Can be 0 (neutral), 1 (in favor) or -1 (against)'", null: true

      field :up_votes, Int, "The number of comment's upVotes", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.up_votes.size
        end
      end

      field :up_voted, Boolean, "Check if the current user has upvoted the comment", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.up_voted_by?(ctx[:current_user])
        end
      end

      field :down_votes, Int, "The number of comment's downVotes", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.down_votes.size
        end
      end

      field :down_voted, Boolean, "Check if the current user has downvoted the comment", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.down_voted_by?(ctx[:current_user])
        end
      end

      field :has_comments, Boolean, "Check if the commentable has comments", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.comment_threads.size.positive?
        end
      end

      field :already_reported, Boolean, "Check if the current user has reported the comment", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.reported_by?(ctx[:current_user])
        end
      end

      field :user_allowed_to_comment, Boolean, "Check if the current user can comment", null: false do
        def resolve_field(obj, _args, _ctx)
          obj.root_commentable.commentable? && obj.root_commentable.user_allowed_to_comment?(ctx[:current_user])
        end
      end
    end
  end
end

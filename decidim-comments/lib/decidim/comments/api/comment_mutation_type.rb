# frozen_string_literal: true

module Decidim
  module Comments
    class CommentMutationType < Decidim::Api::Types::BaseObject
      description "A comment which includes its available mutations"

      field :id, GraphQL::Types::ID, "The Comment's unique ID", null: false

      field :up_vote, Decidim::Comments::CommentType, null: false do
        def resolve_field(obj, _args, ctx)
          VoteCommentResolver.new(weight: 1)
        end
      end

      field :down_vote, Decidim::Comments::CommentType, null: false do
        def resolve_field(obj, _args, ctx)
           VoteCommentResolver.new(weight: -1)
         end
      end
    end
  end
end

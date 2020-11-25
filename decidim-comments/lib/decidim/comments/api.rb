# frozen_string_literal: true

module Decidim
  module Comments
    autoload :AddCommentType, "decidim/comments/api/add_comment_type"
    autoload :CommentMutationType, "decidim/comments/api/comment_mutation_type"
    autoload :CommentType, "decidim/comments/api/comment_type"
    autoload :CommentableInterface, "decidim/comments/api/commentable_interface"
  end
end

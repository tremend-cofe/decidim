# frozen_string_literal: true

module Decidim
  module Comments
    class HideAllCommentsFromAuthorJob < Decidim::HideAllContentFromAuthorJob

      protected
      def base_query
        Decidim::Comments::Comment.not_hidden.where(author: @reportable)
      end
    end
  end
end

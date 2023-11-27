# frozen_string_literal: true

module Decidim
  module Comments
    # A cell to display a comments section for a commentable object.
    class CommentsCell < Decidim::ViewModel
      include Decidim::IconHelper

      delegate :user_signed_in?, to: :controller

      def add_comment
        return if single_comment?
        return if comments_blocked?
        return if user_comments_blocked?

        render :add_comment
      end

      private

      def decidim_comments
        Decidim::Comments::Engine.routes.url_helpers
      end

      def comments
        single_comment? ? [single_comment] : []
      end

      def alignment_enabled?
        model.comments_have_alignment?
      end


      def decidim
        Decidim::Core::Engine.routes.url_helpers
      end

      #
      # def comment_permissions?
      #   [model, current_component].any? do |resource|
      #     resource.try(:permissions).try(:[], "comment")
      #   end
      # end

    end
  end
end

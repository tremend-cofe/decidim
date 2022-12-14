# frozen_string_literal: true

module Decidim
  module Comments
    # A command with all the business logic to update an existing comment
    class UpdateComment < Decidim::Command
      # Public: Initializes the command.
      #
      # comment - Decidim::Comments::Comment
      # current_user - Decidim::User
      # form - A form object with the params.
      def initialize(comment, current_user, form)
        @comment = comment
        @current_user = current_user
        @form = form
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if the form wasn't valid and we couldn't proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if form.invalid? || !comment.authored_by?(current_user)

        update_comment
        dispatch_system_event

        broadcast(:ok)
      end

      private

      attr_reader :form, :comment, :current_user

      def dispatch_system_event
        ActiveSupport::Notifications.publish(
          "decidim.system.comments.comment.updated",
          resource: comment,
          author: current_user,
          locale: I18n.locale
        )
      end

      def update_comment
        parsed = Decidim::ContentProcessor.parse(form.body, current_organization: form.current_organization)

        params = {
          body: { I18n.locale => parsed.rewrite }
        }

        @comment = Decidim.traceability.update!(
          comment,
          current_user,
          params,
          visibility: "public-only",
          edit: true
        )

        CommentCreation.publish(@comment, parsed.metadata)
      end
    end
  end
end

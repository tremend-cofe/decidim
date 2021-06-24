# frozen-string_literal: true

module Decidim
  module Comments
    # This module is used to be included in events triggered by comments.
    #
    module CommentEvent
      extend ActiveSupport::Concern
      include Decidim::Events::AuthorEvent

      included do
        def resource_text(override_translation = nil)
          translated_body = translated_attribute(comment.body, comment.organization, override_translation)
          Decidim::ContentProcessor.render(sanitize_content(render_markdown(translated_body)), "div")
        end

        def author
          comment.normalized_author
        end

        def author_presenter
          return unless author

          @author_presenter ||= case author
                                when Decidim::User
                                  Decidim::UserPresenter.new(author)
                                when Decidim::UserGroup
                                  Decidim::UserGroupPresenter.new(author)
                                end
        end

        def perform_translation?
          organization.enable_machine_translations
        end

        def content_in_same_language?
          return false unless perform_translation?
          return false unless resource_text.respond_to?(:content_original_language)

          comment.content_original_language == I18n.locale.to_s
        end

        def translation_missing?
          return false unless perform_translation?

          comment.body.dig("machine_translations", I18n.locale.to_s).blank?
        end

        def safe_resource_text
          I18n.with_locale(comment.content_original_language) { resource_text }
        end

        def safe_resource_translated_text
          I18n.with_locale(I18n.locale) { resource_text(true) }
        end

        private

        # Private: Initializes the Markdown parser
        def markdown
          @markdown ||= Decidim::Comments::Markdown.new
        end

        # Private: converts the string from markdown to html
        def render_markdown(string)
          markdown.render(string)
        end

        # Private: Returns the comment body sanitized, sanitizing HTML tags
        def sanitize_content(content)
          Decidim::ContentProcessor.sanitize(content)
        end

        def comment
          @comment ||= Decidim::Comments::Comment.find(extra[:comment_id])
        end

        def resource_url_params
          { anchor: "comment_#{comment.id}" }
        end
      end
    end
  end
end

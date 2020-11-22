# frozen_string_literal: true

module Decidim
  module Comments
    # This module's job is to extend the API with custom fields related to
    # decidim-comments.
    module MutationExtensions
      # Public: Extends a type with `decidim-comments`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.included(base)
        base.class_eval do
          field :commentable, Decidim::Comments::CommentableMutationType, description: "A commentable", null: true do
            argument :id, String, "The commentable's ID", required: true
            argument :type, String, "The commentable's class name. i.e. `Decidim::ParticipatoryProcess`", required: true
            argument :locale, String, "The locale for which to get the comments text", required: true
            argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: true

            def resolve_field(object:, args:, context:)
              I18n.locale = args[:locale].presence
              RequestStore.store[:toggle_machine_translations] = args[:toggleTranslations]
              args[:type].constantize.find(args[:id])
            end
          end

          field :comment, Decidim::Comments::CommentMutationType, description: "A comment", null: true do
            argument :id, GraphQL::Types::ID, "The comment's id", required: true
            argument :locale, String, "The locale for which to get the comments text", required: true
            argument :toggle_translations, GraphQL::Types::Boolean, "Whether the user asked to toggle the machine translations or not.", required: true

            def resolve_field(object:, args:, context:)
              I18n.locale = args[:locale].presence
                RequestStore.store[:toggle_machine_translations] = args[:toggleTranslations]
                Comment.find(args["id"])
            end
          end
        end
      end
    end
  end
end

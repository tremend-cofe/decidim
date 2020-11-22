# frozen_string_literal: true

module Decidim
  module Core
    # This interface represents a commentable object.
    module AuthorableInterface
      include Types::BaseInterface
      description "An interface that can be used in authorable objects."

      field :author, Decidim::Core::AuthorInterface, "The resource author", null: true

      def author
        if object.respond_to?(:normalized_author)
          object&.normalized_author
        elsif object.respond_to?(:creator_identity)
          object&.creator_identity
        end
      end
    end
  end
end

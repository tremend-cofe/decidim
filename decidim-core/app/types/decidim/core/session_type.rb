# frozen_string_literal: true

module Decidim
  module Core
    # This type represents the current user session.
    class SessionType < Decidim::Api::Types::BaseObject
      description "The current session"

      field :user, UserInterface, "The current user", null: true

      def user
        object
      end

      field :verified_user_groups, [UserInterface], "The current user verified user groups", null: false

      def verified_user_groups
        Decidim::UserGroups::ManageableUserGroups.for(object).verified
      end
    end
  end
end

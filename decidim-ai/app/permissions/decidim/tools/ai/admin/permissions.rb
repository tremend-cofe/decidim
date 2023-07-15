# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Admin
        class Permissions < Decidim::DefaultPermissions
          def permissions
            return permission_action unless user

            return permission_action if permission_action.scope != :admin

            case permission_action.subject
            when :tools_ai, :forbidden_keywords, :stopwords
              allow!
            end

            permission_action
          end
        end
      end
    end
  end
end

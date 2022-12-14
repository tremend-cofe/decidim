# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Overrides
        module CreateComment
          def create_comment
            return super if respond_to?(:dispatch_system_event, true)
            return super unless Decidim::Tools::Ai.enable_override

            super
            dispatch_overriden_system_event
            comment
          end

          private

          def dispatch_overriden_system_event
            ActiveSupport::Notifications.publish(
              "decidim.system.comments.comment.created",
              resource: comment,
              author: @author,
              locale: I18n.locale
            )
          end
        end
      end
    end
  end
end

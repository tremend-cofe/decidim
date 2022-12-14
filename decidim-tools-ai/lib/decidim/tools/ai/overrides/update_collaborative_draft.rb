# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Overrides
        module UpdateCollaborativeDraft
          def update_collaborative_draft
            return super if respond_to?(:dispatch_system_event, true)
            return super unless Decidim::Tools::Ai.enable_override

            super
            dispatch_overriden_system_event
            collaborative_draft
          end

          private

          def dispatch_overriden_system_event
            ActiveSupport::Notifications.publish(
              "decidim.system.proposals.collaborative_draft.updated",
              resource: collaborative_draft,
              author: current_user,
              locale: I18n.locale
            )
          end
        end
      end
    end
  end
end

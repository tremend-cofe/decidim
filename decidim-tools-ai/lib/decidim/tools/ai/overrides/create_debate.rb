# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Overrides
        module CreateDebate
          def create_debate
            return super if respond_to?(:dispatch_system_event, true)
            return super unless Decidim::Tools::Ai.enable_override

            super
            dispatch_overriden_system_event
            debate
          end

          private

          def dispatch_overriden_system_event
            ActiveSupport::Notifications.publish(
              "decidim.system.debates.debate.created",
              resource: debate,
              author: form.current_user,
              locale: I18n.locale
            )
          end
        end
      end
    end
  end
end

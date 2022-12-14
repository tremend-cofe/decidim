# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Overrides
        module BlockUser
          def call
            return broadcast(:invalid) unless form.valid?

            transaction do
              register_justification!
              block!
              notify_user!
              dispatch_overriden_system_event
            end

            broadcast(:ok, form.user)
          end

          private

          def dispatch_overriden_system_event
            ActiveSupport::Notifications.publish(
              "decidim.system.core.user.blocked",
              resource: form.user,
              author: form.current_user,
              locale: I18n.locale
            )
          end
        end
      end
    end
  end
end

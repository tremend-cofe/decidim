# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Overrides
        module HideResource
          def call
            return broadcast(:invalid) unless hideable?

            hide!

            send_hide_notification_to_author
            dispatch_overriden_system_event

            broadcast(:ok, @reportable)
          end

          private

          def dispatch_overriden_system_event
            ActiveSupport::Notifications.publish(
              "decidim.system.core.resource.hidden",
              resource: @reportable
            )
          end
        end
      end
    end
  end
end

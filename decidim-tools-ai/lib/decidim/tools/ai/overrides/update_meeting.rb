# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Overrides
        module UpdateMeeting
          def update_meeting!
            return super if respond_to?(:dispatch_system_event, true)
            return super unless Decidim::Tools::Ai.enable_override

            super
            dispatch_overriden_system_event
            meeting
          end

          private

          def dispatch_overriden_system_event
            ActiveSupport::Notifications.publish(
              "decidim.system.meetings.meeting.updated",
              resource: meeting,
              author: current_user,
              locale: I18n.locale
            )
          end
        end
      end
    end
  end
end

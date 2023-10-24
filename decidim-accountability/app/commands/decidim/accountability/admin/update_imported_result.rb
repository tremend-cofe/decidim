# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateImportedResult < Decidim::Commands::UpdateResource
        include Decidim::Accountability::ResultCommandHelper

        fetch_form_attributes :scope, :category, :parent_id, :title,
                              :description, :start_date, :end_date, :progress, :decidim_accountability_status_id,
                              :external_id, :weight

        # Initializes an UpdateResult Command.
        #
        # form - The form from which to get the data.
        # result - The current instance of the result to be updated.
        def initialize(form, result, parent_id = nil)
          super(form, result)
          @parent_id = parent_id
        end

        private

        def update_resource
          super
          link_proposals
          link_meetings
          link_projects
          send_notifications if should_notify_followers?
        end

        def send_notifications
          resource.linked_resources(:proposals, "included_proposals").each do |proposal|
            Decidim::EventsManager.publish(
              event: "decidim.events.accountability.result_progress_updated",
              event_class: Decidim::Accountability::ResultProgressUpdatedEvent,
              resource:,
              affected_users: proposal.notifiable_identities,
              followers: proposal.followers - proposal.notifiable_identities,
              extra: {
                progress: resource.progress,
                proposal_id: proposal.id
              }
            )
          end
        end

        def should_notify_followers?
          resource.previous_changes["progress"].present?
        end

        def attributes
          super.merge(parent_id: @parent_id)
        end
      end
    end
  end
end

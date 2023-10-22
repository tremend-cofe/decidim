# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateResult < Decidim::Commands::UpdateResource
        fetch_form_attributes :scope, :category, :parent_id, :title,
                              :description, :start_date, :end_date, :progress, :decidim_accountability_status_id,
                              :external_id, :weight

        private

        def update_resource
          super
          link_proposals
          link_meetings
          link_projects
          send_notifications if should_notify_followers?
        end

        def attributes
          super.merge(external_id: form.external_id.presence)
        end

        def proposals
          @proposals ||= resource.sibling_scope(:proposals).where(id: form.proposal_ids)
        end

        def projects
          @projects ||= resource.sibling_scope(:projects).where(id: form.project_ids)
        end

        def meeting_ids
          @meeting_ids ||= proposals.flat_map do |proposal|
            proposal.linked_resources(:meetings, "proposals_from_meeting").pluck(:id)
          end.uniq
        end

        def meetings
          @meetings ||= resource.sibling_scope(:meetings).where(id: meeting_ids)
        end

        def link_proposals
          resource.link_resources(proposals, "included_proposals")
        end

        def link_projects
          resource.link_resources(projects, "included_projects")
        end

        def link_meetings
          resource.link_resources(meetings, "meetings_through_proposals")
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
      end
    end
  end
end

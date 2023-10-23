# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Result from the admin
      # panel.
      class CreateResult < Decidim::Commands::CreateResource
        fetch_form_attributes :scope, :category, :parent_id, :title, :description, :start_date,
                              :end_date, :progress, :decidim_accountability_status_id, :external_id, :weight

        private

        attr_reader :resource
        alias result resource

        def create_resource
          super
          link_meetings
          link_proposals
          link_projects
          notify_proposal_followers
        end

        def resource_class = Decidim::Accountability::Result

        def extra_params = { visibility: "all" }

        def attributes = super.merge(component: form.current_component, external_id: form.external_id.presence)

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

        def notify_proposal_followers
          proposals.each do |proposal|
            Decidim::EventsManager.publish(
              event: "decidim.events.accountability.proposal_linked",
              event_class: Decidim::Accountability::ProposalLinkedEvent,
              resource:,
              affected_users: proposal.notifiable_identities,
              followers: proposal.followers - proposal.notifiable_identities,
              extra: {
                proposal_id: proposal.id
              }
            )
          end
        end
      end
    end
  end
end

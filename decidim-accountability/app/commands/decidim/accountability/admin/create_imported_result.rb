# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Result from the admin
      # panel.
      class CreateImportedResult < Decidim::Commands::CreateResource
        include Decidim::Accountability::ResultCommandHelper

        fetch_form_attributes :scope, :component, :category, :parent_id, :title, :description, :start_date,
                              :end_date, :progress, :decidim_accountability_status_id, :external_id, :weight

        def initialize(form, parent_id = nil)
          super(form)
          @parent_id = parent_id
        end

        private

        attr_reader :resource
        alias result resource

        def attributes
          super.merge(parent_id: @parent_id)
        end

        def create_resource
          super
          link_meetings
          link_proposals
          link_projects
          notify_proposal_followers
        end

        def resource_class = Decidim::Accountability::Result

        def extra_params = { visibility: "all" }

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

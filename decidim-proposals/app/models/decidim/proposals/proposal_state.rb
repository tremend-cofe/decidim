# frozen_string_literal: true

module Decidim
  module Proposals
    class ProposalState < Proposals::ApplicationRecord
      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable

      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes

      translatable_fields :title

      has_many :proposals,
        class_name: "Decidim::Proposals::Proposal",
        foreign_key: "decidim_proposals_proposal_state_id",
        inverse_of: :state,
        dependent: :restrict

      def self.log_presenter_class_for(_log)
        Decidim::Proposals::AdminLog::ProposalStatePresenter
      end
    end
  end
end

# frozen_string_literal: true
# frozen_string_literal: true

module Decidim
  module Proposals
    class HideAllProposalsFromAuthorJob < Decidim::HideAllContentFromAuthorJob

      def perform(reportable, current_user)
        @reportable = reportable.reload

        Decidim::Proposals::Proposal.from_all_author_identities(@reportable).find_each do |content|
          Decidim::Admin::HideResource.new(content, current_user).call if content.created_by?(@reportable)
        end
      end
    end
  end
end


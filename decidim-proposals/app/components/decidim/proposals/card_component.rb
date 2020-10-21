module Decidim
  module Proposals
    class CardComponent < ViewComponent::Base
      def initialize(proposal)
        @proposal = proposal
      end

      private

      attr_reader :proposal

      def title
        helpers.decidim_html_escape(helpers.present(proposal).title)
      end
    end
  end
end

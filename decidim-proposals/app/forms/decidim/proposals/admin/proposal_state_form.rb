# frozen_string_literal: true

module Decidim
  module Proposals
    module Admin
      class ProposalStateForm < Decidim::Form
        include Decidim::TranslatableAttributes

        mimic :proposal_state

        translatable_attribute :title, String
        translatable_attribute :description, String
        attribute :color, String
        attribute :default, Boolean
        attribute :include_in_stats, Boolean

        validates :title, translatable_presence: true
      end
    end
  end
end

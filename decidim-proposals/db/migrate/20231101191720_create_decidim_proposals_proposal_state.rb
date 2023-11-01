# frozen_string_literal: true

class CreateDecidimProposalsProposalState < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_proposals_proposal_states do |t|
      t.jsonb :title
      t.jsonb :description
      t.references :decidim_component, index: true, null: false

      t.timestamps
    end
  end
end

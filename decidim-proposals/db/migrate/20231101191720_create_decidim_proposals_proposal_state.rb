# frozen_string_literal: true

class CreateDecidimProposalsProposalState < ActiveRecord::Migration[6.1]
  def change
    create_table :decidim_proposals_proposal_states do |t|
      t.jsonb :title
      t.jsonb :description
      t.references :decidim_component, index: true, null: false
      t.integer :proposals_count, default: 0, null: false
      t.boolean :default, default: false, null: false
      t.boolean :include_in_stats, default: true, null: false
      t.string :color

      t.timestamps
    end
  end
end

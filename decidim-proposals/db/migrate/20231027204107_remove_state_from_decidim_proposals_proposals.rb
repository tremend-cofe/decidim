# frozen_string_literal: true
class RemoveStateFromDecidimProposalsProposals < ActiveRecord::Migration[6.1]
  def up
    remove_column :decidim_proposals_proposals, :state
  end

  def down
    add_column :decidim_proposals_proposals, :state, :integer, default: 0, null: false
  end
end

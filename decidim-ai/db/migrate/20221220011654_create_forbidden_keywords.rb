# frozen_string_literal: true

class CreateForbiddenKeywords < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_ai_forbidden_keywords do |t|
      t.string :word
      t.belongs_to :organization
      t.timestamps
    end
  end
end

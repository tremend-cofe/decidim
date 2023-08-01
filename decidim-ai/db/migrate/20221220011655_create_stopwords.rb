# frozen_string_literal: true

class CreateStopwords < ActiveRecord::Migration[5.0]
  def change
    create_table :decidim_ai_stopwords do |t|
      t.string :word
      t.belongs_to :organization
      t.timestamps
    end
  end
end

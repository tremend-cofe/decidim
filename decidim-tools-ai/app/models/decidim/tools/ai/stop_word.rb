# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      class StopWord < ApplicationRecord
        self.table_name = :decidim_tools_ai_stopwords

        belongs_to :organization, class_name: "Decidim::Organization"

        validates :word, presence: true, uniqueness: { scope: :organization }
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      class ForbiddenKeyword < ApplicationRecord
        belongs_to :organization, class_name: "Decidim::Organization"

        validates :word, presence: true, uniqueness: { scope: :organization }
      end
    end
  end
end

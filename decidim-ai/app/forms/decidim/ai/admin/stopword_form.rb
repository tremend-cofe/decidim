# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class StopwordForm < Decidim::Form
        mimic :stopword

        attribute :word, String

        validates :word, presence: true

        validate :word_uniqueness

        private

        def word_uniqueness
          return unless current_organization
          return unless Decidim::Ai::StopWord.where(organization: current_organization).exists?(word:)

          errors.add(:word, :taken)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Admin
        class ForbiddenKeywordForm < Decidim::Form
          mimic :forbidden_keyword

          attribute :word, String

          validates :word, presence: true

          validate :word_uniqueness

          private

          def word_uniqueness
            return unless current_organization
            return unless Decidim::Tools::Ai::ForbiddenKeyword.where(organization: current_organization).exists?(word:)

            errors.add(:word, :taken)
          end
        end
      end
    end
  end
end

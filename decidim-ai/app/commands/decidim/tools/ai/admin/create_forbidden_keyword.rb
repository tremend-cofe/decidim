# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class CreateForbiddenKeyword < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          transaction do
            @keyword = Decidim::Ai::ForbiddenKeyword.create!(
              word: @form.word,
              organization: @form.current_organization
            )
          end

          broadcast(:ok, @keyword)
        end
      end
    end
  end
end

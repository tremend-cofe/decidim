# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class CreateStopword < Decidim::Command
        def initialize(form)
          @form = form
        end

        def call
          return broadcast(:invalid) unless @form.valid?

          transaction do
            @keyword = Decidim::Ai::StopWord.create!(
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

# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Admin
        class UpdateForbiddenKeyword < Decidim::Command
          def initialize(word, form, user)
            @form = form
            @word = word
            @current_user = user
          end

          def call
            return broadcast(:invalid) unless @form.valid?

            transaction do
              @word.word = @form.word
              @word.save!
            end

            broadcast(:ok, @word)
          end
        end
      end
    end
  end
end

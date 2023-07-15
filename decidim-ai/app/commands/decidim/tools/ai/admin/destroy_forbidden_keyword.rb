# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class DestroyForbiddenKeyword < Decidim::Command
        def initialize(word, user)
          @forbidden_keyword = word
          @current_ser = user
        end

        def call
          transaction do
            @forbidden_keyword.destroy!
          end

          broadcast(:ok)
        end
      end
    end
  end
end

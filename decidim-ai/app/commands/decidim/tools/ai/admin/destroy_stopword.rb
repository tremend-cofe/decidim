# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class DestroyStopword < Decidim::Command
        def initialize(word, user)
          @stopword = word
          @current_ser = user
        end

        def call
          transaction do
            @stopword.destroy!
          end

          broadcast(:ok)
        end
      end
    end
  end
end

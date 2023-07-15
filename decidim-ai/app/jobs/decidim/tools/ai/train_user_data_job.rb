# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      class TrainUserDataJob < ApplicationJob
        def perform(user, spam_backend = Decidim::Tools::Ai::SpamContent::Repository.new)
          user.reload

          if user.blocked?
            spam_backend.untrain "normal", user.about
            spam_backend.train "spam", user.about
          else
            spam_backend.untrain "spam", user.about
            spam_backend.train "normal", user.about
          end
        end
      end
    end
  end
end

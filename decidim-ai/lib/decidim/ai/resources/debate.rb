# frozen_string_literal: true

module Decidim
  module Ai
    module Resource
      class Debate < Base
        def fields
          [:description, :title]
        end

        def query
          Decidim::Debates::Debate.includes(:moderation)
        end
      end
    end
  end
end

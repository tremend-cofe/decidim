# frozen_string_literal: true

module Decidim
  module Tools
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
end

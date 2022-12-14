# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Resource
        class CollaborativeDraft < Base
          protected

          def fields
            [:body, :title]
          end

          def query
            Decidim::Proposals::CollaborativeDraft.includes(:moderation)
          end
        end
      end
    end
  end
end

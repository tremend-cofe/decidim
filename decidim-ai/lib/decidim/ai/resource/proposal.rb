# frozen_string_literal: true

module Decidim
  module Ai
    module Resource
      class Proposal < Base
        def fields
          [:body, :title]
        end

        def query
          Decidim::Proposals::Proposal.includes(:moderation)
        end
      end
    end
  end
end

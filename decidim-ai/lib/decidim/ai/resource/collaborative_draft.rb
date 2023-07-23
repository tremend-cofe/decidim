# frozen_string_literal: true

module Decidim
  module Ai
    module Resource
      class CollaborativeDraft < Base
        def fields
          [:body, :title]
        end
        # protected
        #
        #
        # def query
        #   Decidim::Proposals::CollaborativeDraft.includes(:moderation)
        # end
      end
    end
  end
end

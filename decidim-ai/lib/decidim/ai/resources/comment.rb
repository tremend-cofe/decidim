# frozen_string_literal: true

module Decidim
  module Ai
    module Resource
      class Comment < Base
        def fields
          [:body]
        end

        def query
          Decidim::Comments::Comment.includes(:moderation)
        end
      end
    end
  end
end

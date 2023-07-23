# frozen_string_literal: true

module Decidim
  module Ai
    module Resource
      class Meeting < Base
        def fields
          [:description, :title, :location_hints, :registration_terms, :closing_report]
        end
        # protected
        #
        # def query
        #   Decidim::Meetings::Meeting.includes(:moderation)
        # end
      end
    end
  end
end

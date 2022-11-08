# frozen_string_literal: true

module Decidim
  module Meetings
    class HideAllMeetingsFromAuthorJob < Decidim::HideAllContentFromAuthorJob

      protected
      def base_query
        Decidim::Meetings::Meeting.not_hidden.where(author: @reportable)
      end
    end
  end
end

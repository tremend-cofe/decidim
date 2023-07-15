# frozen_string_literal: true

module Decidim
  module Ai
    class UserSpamAnalyzerJob < GenericSpamAnalyzerJob
      def perform(reportable)
        @author = reportable

        classifier.classify!(reportable.about, locale)

        return unless classifier.score >= Decidim::Ai.spam_treshold

        Decidim::CreateUserReport.call(form, reportable, reporting_user)
        # do
        #   on(:ok) { ; }
        #   on(:invalid) { ; }
        # end
      end
    end
  end
end

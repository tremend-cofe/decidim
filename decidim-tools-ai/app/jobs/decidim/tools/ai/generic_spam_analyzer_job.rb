# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      class GenericSpamAnalyzerJob < ApplicationJob
        include Decidim::TranslatableAttributes

        def perform(reportable, author, locale, fields)
          @author = author
          fields.each do |field|
            I18n.with_locale(locale) do
              classifier.classify!(translated_attribute(reportable.send(field)), locale)
            end
          end

          return unless classifier.score >= Decidim::Tools::Ai.spam_treshold

          Decidim::CreateReport.call(form, reportable, reporting_user)
          # do
          #   on(:ok) { ; }
          #   on(:invalid) { ; }
          # end
        end

        private

        def classifier
          @classifier ||= Decidim::Tools::Ai.spam_classifier.constantize.new(@author.organization)
        end

        def form
          @form ||= Decidim::ReportForm.new(reason: "spam", details: classifier.details)
        end

        def reporting_user
          @reporting_user ||= Decidim::User.find_by!(email: Decidim::Tools::Ai.reporting_user_email)
        end
      end
    end
  end
end

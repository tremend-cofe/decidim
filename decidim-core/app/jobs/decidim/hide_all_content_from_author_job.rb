# frozen_string_literal: true

module Decidim
  class HideAllContentFromAuthorJob < ApplicationJob
    queue_as :user_report

    def perform(reportable, current_user)
      @reportable = reportable.reload

      articificial_ctx = { current_user:, current_organization: current_user.organization }
      user_params = {
        reason: "does_not_belong",
        details: I18n.t("decidim.shared.flag_user_modal.frontend_blocked")
      }
      base_query.find_each do |content|
        report_form = Decidim::ReportForm.from_params(user_params).with_context(articificial_ctx)
        Decidim::CreateReport.call(report_form, content, current_user) do
          on(:ok) do
            Decidim::Admin::HideResource.new(content, current_user).call do
              on(:invalid) { raise ActiveRecord::ActiveRecordError, "Something not working" }
            end
          end
          on(:invalid) { raise ActiveRecord::ActiveRecordError, "Something not working" }
        end
      end
    end
  end
end

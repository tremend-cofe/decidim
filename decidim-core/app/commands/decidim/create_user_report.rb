# frozen_string_literal: true

module Decidim
  # A command with all the business logic when a user creates a report.
  class CreateUserReport < Decidim::Command
    # Public: Initializes the command.
    #
    # form         - A form object with the params.
    # reportable   - The resource being reported
    # current_user - The current user.
    def initialize(form, reportable, current_user)
      @form = form
      @reportable = reportable
      @current_user = current_user
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid, together with the report.
    # - :invalid if the form wasn't valid and we couldn't proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) if form.invalid?

      transaction do
        find_or_create_moderation!
        create_report!
        update_report_count!
        send_notification_to_admins!
        block_user! if form.block == true
        publish_hide_event if form.hide
      end

      broadcast(:ok, report)
    end

    private

    attr_reader :form, :report, :reportable

    def publish_hide_event
      ActiveSupport::Notifications.publish("decidim.system.events.hide_user_created_content", { reportable:, current_user: })
    end

    def block_user!
      user_params = {
        justification: I18n.t("decidim.shared.flag_user_modal.frontend_blocked"),
        user_id: @reportable.id
      }
      articificial_ctx = { current_user:, current_organization: current_user.organization }
      block_user_form = Decidim::Admin::BlockUserForm.from_params(user_params).with_context(articificial_ctx)

      Decidim::Admin::BlockUser.call(block_user_form) do
        on(:invalid) do
          raise ActiveRecord::Rollback
        end
      end
    end

    def find_or_create_moderation!
      @moderation = UserModeration.find_or_create_by!(user: @reportable)
    end

    def create_report!
      @report = UserReport.create!(
        moderation: @moderation,
        user: @current_user,
        reason: form.reason,
        details: form.details
      )
    end

    def update_report_count!
      @moderation.update!(report_count: @moderation.report_count + 1)
    end

    def send_notification_to_admins!
      @current_user.organization.admins.each do |admin|
        next unless admin.email_on_moderations

        Decidim::UserReportJob.perform_later(admin, report)
      end
    end
  end
end

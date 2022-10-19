# frozen_string_literal: true

module Decidim
  module Admin
    class ModeratedUsersController < Decidim::Admin::ApplicationController
      layout "decidim/admin/users"

      def ignore
        enforce_permission_to :unreport, :moderate_users

        Admin::UnreportUser.call(reportable, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("reportable.unreport.success", scope: "decidim.moderations.admin")
            redirect_to officializations_path
          end

          on(:invalid) do
            flash.now[:alert] = I18n.t("reportable.unreport.invalid", scope: "decidim.moderations.admin")
            redirect_to officializations_path
          end
        end
      end

      private

      def reportable
        @reportable ||= base_query_finder.find(params[:id]).user
      end

      def base_query_finder
        UserModeration.joins(:user).where(decidim_users: { decidim_organization_id: current_organization.id })
      end

      def collection
        target_scope = params[:blocked] && params[:blocked] == "true" ? :blocked : :unblocked
        base_query_finder.send(target_scope)
      end
    end
  end
end

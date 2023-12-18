# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing all areas at the admin panel.

    # i18n-tasks-use t('decidim.admin.areas.create.success')
    # i18n-tasks-use t('decidim.admin.areas.create.error')
    # i18n-tasks-use t('decidim.admin.areas.update.success')
    # i18n-tasks-use t('decidim.admin.areas.update.error')
    # i18n-tasks-use t('decidim.admin.areas.destroy.success')
    class AreasController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :area, :organization_areas

      permission_subject :area
      # with_action :index, secure: true
      with_action :create, secure: true
      with_action :update, secure: true
      with_action :destroy, secure: true

      def index
        enforce_permission_to :read, :area
        @areas = organization_areas
      end

      def destroy
        DestroyArea.call(area, current_user) do
          on(:ok) do
            flash[:notice] = I18n.t("destroy.success", scope:)
            redirect_to areas_path
          end
          on(:has_spaces) do
            flash[:alert] = I18n.t("destroy.has_spaces", scope:)
            redirect_to areas_path
          end
        end
      end

      private

      def form_class = Decidim::Admin::AreaForm

      def create_command = Decidim::Admin::CreateArea

      def update_command = Decidim::Admin::UpdateArea

      def destroy_command = Decidim::Commands::DestroyArea

      def scope = "decidim.admin.areas"

      def object_name = :area

      def tab_menu_name = :admin_areas_menu

      def organization_areas
        current_organization.areas
      end

      def area
        return @area if defined?(@area)

        @area = organization_areas.find_by(id: params[:id])
      end
    end
  end
end

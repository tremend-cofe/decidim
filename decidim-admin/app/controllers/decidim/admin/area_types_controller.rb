# frozen_string_literal: true

module Decidim
  module Admin
    # Controller that allows managing areatypes to group areas

    # i18n-tasks-use t('decidim.admin.area_types.create.success')
    # i18n-tasks-use t('decidim.admin.area_types.create.error')
    # i18n-tasks-use t('decidim.admin.area_types.update.success')
    # i18n-tasks-use t('decidim.admin.area_types.update.error')
    # i18n-tasks-use t('decidim.admin.area_types.destroy.success')
    class AreaTypesController < Decidim::Admin::ApplicationController
      include Decidim::Admin::Concerns::HasTabbedMenu

      layout "decidim/admin/settings"

      add_breadcrumb_item_from_menu :admin_settings_menu

      helper_method :area_types

      permission_subject :area_type
      with_action :index, secure: true
      with_action :create, secure: true
      with_action :update, secure: true
      with_action :destroy, secure: true

      private

      def form_class = Decidim::Admin::AreaTypeForm

      def create_command = Decidim::Admin::CreateAreaType

      def update_command = Decidim::Admin::UpdateAreaType

      def destroy_command = Decidim::Commands::DestroyResource

      def scope = "decidim.admin.area_types"

      def object_name = :area_type

      def tab_menu_name = :admin_areas_menu

      def area_type
        @area_type ||= area_types.find(params[:id])
      end

      def area_types
        current_organization.area_types
      end
    end
  end
end

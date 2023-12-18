# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasCrudController
        module Update
          extend ActiveSupport::Concern

          include Decidim::Admin::Concerns::HasCrudController::Contract

          def update_command = raise "#{self.class.name} must implement '#{__method__}' method"

          def edit
            @form = form(form_class).from_model(send(object_name))
          end

          def update
            @form = form(form_class).from_params(params)

            update_command.call(@form, send(object_name)) do
              on(:ok) do
                flash[:notice] = I18n.t("update.success", scope:)
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("update.error", scope:)
                render :edit
              end
            end
          end

          included do
            before_action :enforce_update_permission, only: [:edit, :update]

            protected

            def enforce_update_permission
              return if crud_actions.dig(:update, :secure) == false
              raise "#{self.class.name} must implement 'permission_subject' method" unless respond_to?(:permission_subject)

              enforce_permission_to :update, permission_subject, object_name => send(object_name)
            end
          end
        end
      end
    end
  end
end

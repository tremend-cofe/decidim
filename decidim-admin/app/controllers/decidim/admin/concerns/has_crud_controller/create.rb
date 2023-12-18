# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasCrudController
        module Create
          extend ActiveSupport::Concern
          include Decidim::Admin::Concerns::HasCrudController::Contract

          def create_command = raise "#{self.class.name} must implement '#{__method__}' method"

          def new
            @form = form(form_class).instance
          end

          def create
            @form = form(form_class).from_params(params)

            create_command.call(@form) do
              on(:ok) do
                flash[:notice] = I18n.t("create.success", scope:)
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("create.error", scope:)
                render :new
              end
            end
          end

          included do
            before_action :enforce_create_permission, only: [:new, :create]

            protected

            def enforce_create_permission
              return if crud_actions.dig(:create, :secure) == false
              raise "#{self.class.name} must implement 'permission_subject' method" unless respond_to?(:permission_subject)

              enforce_permission_to :create, permission_subject
            end
          end
        end
      end
    end
  end
end

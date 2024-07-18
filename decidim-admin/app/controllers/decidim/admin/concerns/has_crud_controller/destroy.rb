# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasCrudController
        module Destroy
          extend ActiveSupport::Concern

          include Decidim::Admin::Concerns::HasCrudController::Contract

          def destroy_command = raise "#{self.class.name} must implement '#{__method__}' method"

          def destroy
            destroy_command.call(send(object_name), current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("destroy.success", scope:)
                redirect_to action: :index
              end
            end
          end

          included do
            before_action :enforce_destroy_permission, only: :destroy

            protected

            def enforce_destroy_permission
              return if crud_actions.dig(:destroy, :secure) == false
              raise "#{self.class.name} must implement 'authorization_scope' method" unless respond_to?(:authorization_scope)

              enforce_permission_to :destroy, authorization_scope, object_name => send(object_name)
            end
          end
        end
      end
    end
  end
end

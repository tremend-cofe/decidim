# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasCrudController
        module Show
          extend ActiveSupport::Concern

          def show; end

          included do
            before_action :enforce_show_permission, only: :show

            protected

            def enforce_show_permission
              return if crud_actions.dig(:show, :secure) == false
              raise "#{self.class.name} must implement 'authorization_scope' method" unless respond_to?(:authorization_scope)

              enforce_permission_to :read, authorization_scope, object_name => send(object_name)
            end
          end
        end
      end
    end
  end
end

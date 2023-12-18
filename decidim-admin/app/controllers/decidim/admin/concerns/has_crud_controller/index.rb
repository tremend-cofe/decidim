# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasCrudController
        module Index
          extend ActiveSupport::Concern

          def index; end

          included do
            before_action :enforce_index_permission, only: :index

            protected

            def enforce_index_permission
              return if crud_actions.dig(:index, :secure) == false
              raise "#{self.class.name} must implement 'permission_subject' method" unless respond_to?(:permission_subject)

              enforce_permission_to :read, permission_subject
            end
          end
        end
      end
    end
  end
end

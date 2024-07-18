# frozen_string_literal: true

module Decidim
  module Admin
    module Concerns
      module HasCrudController
        extend ActiveSupport::Concern

        module Contract
          def form_class = raise "#{self.class.name} must implement '#{__method__}' method"

          def scope = raise "#{self.class.name} must implement '#{__method__}' method"

          def object_name = raise "#{self.class.name} must implement '#{__method__}' method"
        end

        included do
          class_attribute :crud_actions
          class_attribute :authorization_scope

          self.crud_actions = {
            create: { enabled: false, secure: true, module: Decidim::Admin::Concerns::HasCrudController::Create },
            index: { enabled: false, secure: true, module: Decidim::Admin::Concerns::HasCrudController::Index },
            show: { enabled: false, secure: true, module: Decidim::Admin::Concerns::HasCrudController::Show },
            update: { enabled: false, secure: true, module: Decidim::Admin::Concerns::HasCrudController::Update },
            destroy: { enabled: false, secure: true, module: Decidim::Admin::Concerns::HasCrudController::Destroy }
          }

          def self.with_action(action_name, secure: false)
            crud_actions[action_name].merge({ enabled: true, secure: })

            include crud_actions[action_name][:module]
          end

          def self.authorization_scope(value)
            self.authorization_scope = value
          end
        end
      end
    end
  end
end

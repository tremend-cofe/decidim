# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Admin
        class ApplicationController < Decidim::Admin::ApplicationController
          layout "decidim/admin/tools_ai"

          register_permissions(::Decidim::Tools::Ai::Admin::ApplicationController,
                               ::Decidim::Tools::Ai::Admin::Permissions,
                               ::Decidim::Admin::Permissions)

          def permission_class_chain
            ::Decidim.permissions_registry.chain_for(::Decidim::Tools::Ai::Admin::ApplicationController)
          end
        end
      end
    end
  end
end

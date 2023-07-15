# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class ApplicationController < Decidim::Admin::ApplicationController
        layout "decidim/admin/tools_ai"

        register_permissions(::Decidim::Ai::Admin::ApplicationController,
                             ::Decidim::Ai::Admin::Permissions,
                             ::Decidim::Admin::Permissions)

        def permission_class_chain
          ::Decidim.permissions_registry.chain_for(::Decidim::Ai::Admin::ApplicationController)
        end
      end
    end
  end
end

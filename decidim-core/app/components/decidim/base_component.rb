# frozen_string_literal: true

module Decidim
  class BaseComponent < ViewComponent::Base
    delegate :current_component,
             :current_organization,
             :current_participatory_space,
             :current_user,
             :translated_attribute,
             :icon,
             :decidim_sanitize_admin,
             :decidim,
             to: :helpers

    def cell(name, model, options = {}, &)
      ActiveSupport::Deprecation.warn("cell is deprecated and will be removed in Decidim 0.28. Use viewComponents instead.", caller)

      helpers.cell(name, model, options = {}, &)
    end
  end
end

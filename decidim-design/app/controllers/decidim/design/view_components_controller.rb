# frozen_string_literal: true
# frozen_string_literal: true

module Decidim
  module Design
    class ViewComponentsController < Decidim::Design::ApplicationController
      include ViewComponent::PreviewActions

      helper Decidim::SanitizeHelper

      helper_method :sections

      helper_method :preview_view_component_path

      def preview_view_component_path(...)
        Rails.application.routes.url_helpers.preview_view_component_path(...)
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module ContentBlocks
    module HighlightedContentBanner
      class MainCell < Decidim::ViewModel
        include Decidim::SanitizeHelper
        def show
          return unless current_organization.highlighted_content_banner_enabled
          render
        end
      end
    end
  end
end

# frozen_string_literal: true

class Decidim::ContentBlocks::HighlightedContentBannerComponent < Decidim::ContentBlocks::BaseComponent

  def render? = organization.highlighted_content_banner_enabled
end

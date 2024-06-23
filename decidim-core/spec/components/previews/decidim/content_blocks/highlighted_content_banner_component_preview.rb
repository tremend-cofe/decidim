# frozen_string_literal: true

class Decidim::ContentBlocks::HighlightedContentBannerComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "highlighted_content_banner",
      scope_name: "homepage",
      organization:
    )

    # usually rendered with
    render(content_block.component)
  end

  private
  def organization
    Decidim::Organization.new(
      highlighted_content_banner_enabled: true,
      highlighted_content_banner_title: { en: "Highlighted content banner" },
      highlighted_content_banner_short_description: { en: "Highlighted content description" },
      highlighted_content_banner_action_title: { en: "Action title" },
      highlighted_content_banner_action_subtitle: { en: "Action subtitle" },
      highlighted_content_banner_action_url: "https://example.com",
      highlighted_content_banner_image: Decidim::Dev.test_file("city.jpeg", "image/jpeg")
    )
  end
end

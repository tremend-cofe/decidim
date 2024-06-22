# frozen_string_literal: true

class Decidim::ContentBlocks::HeroComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "hero",
      scope_name: "homepage",
      settings: {
        "welcome_text_en": "This is the welcome text for Hero"
      }
    )

    # usually rendered with
    render(content_block.component)
  end
end

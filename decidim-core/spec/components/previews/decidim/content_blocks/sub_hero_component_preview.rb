# frozen_string_literal: true

class Decidim::ContentBlocks::SubHeroComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "sub_hero",
      scope_name: "homepage",
      organization:
    )

    # usually rendered with
    render(content_block.component)
  end

  private

  def organization
    Decidim::Organization.new(
      users_registration_mode: "enabled",
      description: { en: "My super long description My super long description My super long description My super long description " }
    )
  end
end

# frozen_string_literal: true

class Decidim::ContentBlocks::FooterSubHeroComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "footer_sub_hero",
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
      name: { en: "My test organization" }
    )
  end
end

# frozen_string_literal: true

class Decidim::ContentBlocks::LastActivityComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "last_activity",
      scope_name: "homepage",
      organization: Decidim::Organization.first
    )

    # usually rendered with
    render(content_block.component)
  end
end

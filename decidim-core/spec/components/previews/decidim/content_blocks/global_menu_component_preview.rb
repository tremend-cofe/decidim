# frozen_string_literal: true

class Decidim::ContentBlocks::GlobalMenuComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "global_menu",
      scope_name: "homepage"
    )

    # usually rendered with
    render(content_block.component)
  end
end

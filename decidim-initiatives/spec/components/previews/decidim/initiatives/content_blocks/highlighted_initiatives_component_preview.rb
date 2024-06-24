# frozen_string_literal: true

class Decidim::Initiatives::ContentBlocks::HighlightedInitiativesComponentPreview < ViewComponent::Preview
  def default

    # example content block object
    content_block =  Decidim::ContentBlock.new(
      manifest_name: "highlighted_initiatives",
      scope_name: "homepage"
    )

    # usually rendered with
    render(content_block.component)
  end
end

# frozen_string_literal: true

class Decidim::Conferences::ContentBlocks::HighlightedConferencesComponentPreview < ViewComponent::Preview
  def default

    # example content block object
    content_block =  Decidim::ContentBlock.new(
      manifest_name: "highlighted_conferences",
      scope_name: "homepage"
    )

    # usually rendered with
    render(content_block.component)
  end
end

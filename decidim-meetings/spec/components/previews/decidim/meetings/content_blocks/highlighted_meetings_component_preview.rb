# frozen_string_literal: true

class Decidim::Meetings::ContentBlocks::HighlightedMeetingsComponentPreview < ViewComponent::Preview
  def default

    # example content block object
    content_block =  Decidim::ContentBlock.new(
      manifest_name: "upcoming_meetings",
      scope_name: "homepage"
    )

    # usually rendered with
    render(content_block.component)
  end
end

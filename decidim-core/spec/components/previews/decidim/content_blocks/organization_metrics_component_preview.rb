# frozen_string_literal: true

class Decidim::ContentBlocks::OrganizationMetricsComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "metrics",
      scope_name: "homepage"
    )

    # usually rendered with
    render(content_block.component)
  end
end

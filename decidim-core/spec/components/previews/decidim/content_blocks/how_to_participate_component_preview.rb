# frozen_string_literal: true

class Decidim::ContentBlocks::HowToParticipateComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "how_to_participate",
      scope_name: "homepage",
      organization:
    )

    # usually rendered with
    render(content_block.component)
  end

  private

  def organization
    Decidim::Organization.new( name: { en: "My example organization" } )
  end
end

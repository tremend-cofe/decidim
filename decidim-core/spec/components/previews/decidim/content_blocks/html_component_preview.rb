# frozen_string_literal: true

class Decidim::ContentBlocks::HtmlComponentPreview < ViewComponent::Preview
  def default
    # example content block object
    content_block = Decidim::ContentBlock.new(
      manifest_name: "html",
      scope_name: "homepage",
      settings: {
        html_content_en: %(<code>This is a Decidim world</code>)
      },
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

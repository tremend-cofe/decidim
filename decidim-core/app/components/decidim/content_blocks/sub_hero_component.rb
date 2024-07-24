# frozen_string_literal: true

class Decidim::ContentBlocks::SubHeroComponent < Decidim::ContentBlocks::BaseComponent
  def render? = translated_attribute(organization.description).present?

  def organization_description
    desc = decidim_sanitize_admin(translated_attribute(organization.description))

    # Strip the surrounding paragraph tag because it is not allowed within
    # a <hN> element.
    desc.gsub(%r{</p>\s+<p>}, "<br><br>").gsub(%r{<p>(((?!</p>).)*)</p>}mi, "\\1")
  end
end

# frozen_string_literal: true

class Decidim::ContentBlocks::HtmlComponent < Decidim::ContentBlocks::BaseComponent

  def block_id = "html-block-#{content_block.id}"

  def html_content = translated_attribute(content_block.settings.html_content).html_safe
end

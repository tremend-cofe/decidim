# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class HtmlCell < Decidim::ViewModel
      def block_id
        "html-block-#{model.manifest_name.parameterize.tr("_", "-")}"
      end

      def html_content
        translated_attribute(model.settings.html_content).html_safe
      end
    end
  end
end

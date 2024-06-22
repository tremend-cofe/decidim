# frozen_string_literal: true

module Decidim
  module ContentBlocks
    class BaseComponent < Decidim::BaseComponent
      def initialize(content_block)
        @content_block = content_block
      end

      protected

      attr_reader :content_block

      delegate :settings, :images_container, to: :content_block
    end
  end
end

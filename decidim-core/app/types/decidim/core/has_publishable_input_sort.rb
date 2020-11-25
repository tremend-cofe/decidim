# frozen_string_literal: true

module Decidim
  module Core
    module HasPublishableInputSort
      def self.included(child_class)
        child_class.argument :published_at, String, "Sort by date of publication, valid values are ASC or DESC", required: false
      end
    end
  end
end

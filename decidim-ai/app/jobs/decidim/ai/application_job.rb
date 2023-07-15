# frozen_string_literal: true

module Decidim
  module Ai
    class ApplicationJob < Decidim::ApplicationJob
      queue_as :spam_analysis
    end
  end
end

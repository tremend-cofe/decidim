# frozen_string_literal: true

module Decidim
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ai

      paths["db/migrate"] = nil
      # paths["lib/tasks"] = nil

      initializer "decidim_ai.classifiers" do |app|
        Decidim::Ai.spam_detection_strategy.register_classifier(:bayes, Decidim::Ai::SpamContent::BayesStrategy)
      end
      def load_seed
        nil
      end
    end
  end
end

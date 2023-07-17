# frozen_string_literal: true

require "classifier-reborn"

module Decidim
  module Ai
    module SpamContent
      class BayesStrategy < BaseStrategy
        def initialize(options = {})
          redis_backend = ClassifierReborn::BayesRedisBackend.new options
          @backend = ClassifierReborn::Bayes.new :spam, :ham, backend: redis_backend
        end

        def train(classification, content)
          @backend.train(classification, content)
        end

        def untrain(classification, content)
          @backend.untrain(classification, content)
        end

        def classify(content)
          @classifier.classify(content)
        end

        def log
          "The Classification engine marked this as ..."
        end
      end
    end
  end
end

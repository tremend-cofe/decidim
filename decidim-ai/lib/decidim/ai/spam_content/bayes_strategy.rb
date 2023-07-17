# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      class BayesStrategy < BaseStrategy
        def initialize(options = {})
          @backend = ClassifierReborn::BayesRedisBackend.new(options)
        end
      end
    end
  end
end

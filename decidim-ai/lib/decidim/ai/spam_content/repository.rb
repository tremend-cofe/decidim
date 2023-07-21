# frozen_string_literal: true

module Decidim
  module Ai
    module SpamContent
      class Repository
        delegate :classify_with_score, :classifications, :reset, :classify, :train, :untrain, to: :classifier

        def self.reset!
          new.reset
        end

        def self.train!
          new.train!
        end

        def train!
          reset
          load_sample_data!

          classifier = Decidim::Ai.spam_detection_instance
          config.trained_models.each do |model|
            wrapped = Decidim::Ai::Resource::Wrapper.new(model.constantize)
            wrapped.train(classifier)
          end
          save_model!
        end

        def self.load_from_file!(file)
          new.load_from_file!(file)
        end

        def load_from_file!(file)
          Decidim::Ai::LoadDataset.call(file)
        end

        private

        def plugin_path
          Gem.loaded_specs["decidim-tools-ai"].full_gem_path
        end

        def load_sample_data!
          return unless config.load_vendor_data

          Dir.glob("#{plugin_path}/data/*.csv").each do |file|
            Decidim::Ai::LoadDataset.call(file)
          end
        end
      end
    end
  end
end

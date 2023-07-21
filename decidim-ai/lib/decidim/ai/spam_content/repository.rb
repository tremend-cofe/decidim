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

          classifier = Decidim::Ai.spam_detection_service.constantize.new(user.organization)
          config.trained_models.each do |model|
            wrapped = Decidim::Ai::Resource::Wrapper.new(model.constantize)
            wrapped.train(classifier)
          end
          save_model!
        end

        def backend
          @backend ||= case config.backend
                       when :memory
                         ClassifierReborn::BayesMemoryBackend.new
                       when :redis
                         ClassifierReborn::BayesRedisBackend.new(**config.redis_configuration)
                       else
                         raise InvalidBackendError, "Unknown backend for classifier. Available options are  :memory, :redis but #{config.backend.inspect} provided"
                       end
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

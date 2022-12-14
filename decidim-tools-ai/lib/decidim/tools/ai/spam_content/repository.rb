# frozen_string_literal: true

module Decidim
  module Tools
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

            config.trained_models.each do |model|
              wrapped = Decidim::Tools::Ai::Resource::Wrapper.new(model.constantize)
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

          def self.load_from_file!(path, file)
            new.load_from_file!(path, file)
          end

          def load_from_file!(path, file)
            Decidim::Tools::Ai::Resource::ProvidedFile.new.add_training_data!(classifier, path, file)
          end

          private

          def plugin_path
            Gem.loaded_specs["decidim-tools-ai"].full_gem_path
          end

          def files
            %w(
              data/blocked_accounts.csv
              data/spam_comments.csv
              data/sms-spam.csv
            )
          end

          def load_sample_data!
            return unless config.load_vendor_data

            files.each do |file|
              load_from_file!(plugin_path, file)
            end
          end

          def persisted_file
            Rails.root.join("bayes-classifier.dat")
          end

          def save_model!
            return unless memory_backend?

            File.binwrite(persisted_file, Marshal.dump(classifier))
          end

          def config
            Decidim::Tools::Ai
          end

          def options
            { backend: }.merge(config.spam_classifier_options)
          end

          def categories
            %w(normal spam)
          end

          def classifier
            @classifier ||=
              if memory_backend? && File.exist?(persisted_file)
                # rubocop:disable Security/MarshalLoad
                internal_classifier = Marshal.load(File.binread(persisted_file))
                # rubocop:enable Security/MarshalLoad
                @backend = internal_classifier.instance_variable_get(:@backend)
                internal_classifier
              else
                ClassifierReborn::Bayes.new categories, **options
              end
          end

          def memory_backend?
            config.backend == :memory
          end
        end
      end
    end
  end
end

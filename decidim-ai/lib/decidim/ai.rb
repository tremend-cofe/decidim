# frozen_string_literal: true

require "classifier-reborn"
require "cld"
require "decidim/ai/admin"
require "decidim/ai/engine"
require "decidim/ai/admin_engine"
require "decidim/ai/spam_content"

module Decidim
  # This namespace holds the logic of the `Tools::Ai` module. This module
  # allows admins to perform various Artificial Inteligence activities like
  # spam detection.
  module Ai
    module Resource
      autoload :Base, "decidim/ai/resource/base"
      autoload :Comment, "decidim/ai/resource/comment"
      autoload :Meeting, "decidim/ai/resource/meeting"
      autoload :Proposal, "decidim/ai/resource/proposal"
      autoload :CollaborativeDraft, "decidim/ai/resources/collaborative_draft"
      autoload :Debate, "decidim/ai/resources/debate"
      autoload :UserBaseEntity, "decidim/ai/resources/user_base_entity"
      autoload :ProvidedFile, "decidim/ai/resources/provided_file"
      autoload :Wrapper, "decidim/ai/resources/wrapper"
    end

    autoload :LanguageDetectionService, "decidim/ai/language_detection_service"
    autoload :SpamDetectionService, "decidim/ai/spam_detection_service"
    autoload :StrategyRegistry, "decidim/ai/strategy_registry"
    autoload :LoadDataset, "decidim/ai/load_dataset"

    module SpamContent
      autoload :BaseStrategy, "decidim/ai/spam_content/base_strategy"
      autoload :BayesStrategy, "decidim/ai/spam_content/bayes_strategy"
    end

    include ActiveSupport::Configurable

    # You can configure the spam treshold for the spam detection service.
    # The treshold is a float value between 0 and 1.
    # The default value is 0.5
    # Any value below the treshold will be considered spam.
    config_accessor :spam_treshold do
      0.5
    end
    # Registered analyzers.
    # You can register your own analyzer by adding a new entry to this array.
    # The entry must be a hash with the following keys:
    # - name: the name of the analyzer
    # - strategy: the class of the strategy to use
    # - options: a hash with the options to pass to the strategy
    # Example:
    # config.registered_analyzers = [
    #   {
    #     name: :bayes,
    #     strategy: Decidim::Ai::SpamContent::BayesStrategy,
    #     options: {
    #       adapter: :redis,
    #       params: {
    #         url:                lambda { ENV["REDIS_URL"] }
    #         scheme:             "redis"
    #         host:               "127.0.0.1"
    #         port:               6379
    #         path:               nil
    #         timeout:            5.0
    #         password:           nil
    #         db:                 0
    #         driver:             nil
    #         id:                 nil
    #         tcp_keepalive:      0
    #         reconnect_attempts: 1
    #         inherit_socket:     false
    #       }
    #     }
    #   }
    # ]
    config_accessor :registered_analyzers do
      [
        { name: :bayes, strategy: Decidim::Ai::SpamContent::BayesStrategy, options: { adapter: :memory, params: {} } }
      ]
    end

    # Language detection service class.
    #
    # If you want to autodetect the language of the content, you can use a class service having the following contract
    #
    # class LanguageDetectionService
    #   def initialize(text)
    #     @text = text
    #   end
    #
    #   def language_code
    #     CLD.detect_language(@text).fetch(:code)
    #   end
    # end
    config_accessor :language_detection_service do
      "Decidim::Ai::LanguageDetectionService"
    end

    # Spam detection service class.
    # If you want to use a different spam detection service, you can use a class service having the following contract
    #
    # class SpamDetectionService
    #   def initialize
    #     @registry = Decidim::Ai.spam_detection_registry
    #   end
    #
    #   def train(category, text)
    #     # train the strategy
    #   end
    #
    #   def classify(text)
    #     # classify the text
    #   end
    #
    #   def untrain(category, text)
    #     # untrain the strategy
    #   end
    #
    #   def classification_log
    #     # return the classification log
    #   end
    # end
    config_accessor :spam_detection_service do
      "Decidim::Ai::SpamDetectionService"
    end

    # This is the email address used by the spam engine to
    # properly identify the user that will report users and content
    config_accessor :reporting_user_email do
      "reporting.user@domain.tld"
    end

    # old config
    config_accessor :spam_treshold do
      0.5
    end

    config_accessor :spam_classifier do
      "Decidim::Ai::SpamContent::Classifier"
    end

    config_accessor :enable_override do
      false
    end

    # Optional: Allow loading to model some spam data provided by decidim, to have a starting point.
    config_accessor :load_vendor_data do
      true
    end

    # Options available are
    # :memory
    # :redis
    config_accessor :backend do
      :memory
    end

    # Options available are:
    #   language:         'en'   Used to select language specific stop words
    #   auto_categorize:  false  When true, enables ability to dynamically declare a category; the default is true if no initial categories are provided
    #   enable_threshold: false  When true, enables a threshold requirement for classifition
    #   threshold:        0.0    Default threshold, only used when enabled
    #   enable_stemmer:   true   When false, disables word stemming
    #   stopwords:        nil    Accepts path to a text file or an array of words, when supplied, overwrites the default list; assign empty string or array to disable stopwords
    config_accessor :spam_classifier_options do
      {}
    end

    # Options available are:
    #   url:                lambda { ENV["REDIS_URL"] }
    #   scheme:             "redis"
    #   host:               "127.0.0.1"
    #   port:               6379
    #   path:               nil
    #   timeout:            5.0
    #   password:           nil
    #   db:                 0
    #   driver:             nil
    #   id:                 nil
    #   tcp_keepalive:      0
    #   reconnect_attempts: 1
    #   inherit_socket:     false
    config_accessor :redis_configuration do
      {}
    end

    config_accessor :trained_models do
      %w(
        Decidim::Ai::Resource::Comment
        Decidim::Ai::Resource::Meeting
        Decidim::Ai::Resource::Proposal
        Decidim::Ai::Resource::CollaborativeDraft
        Decidim::Ai::Resource::Debate
        Decidim::Ai::Resource::UserBaseEntity
      )
    end
    # EOF old config

    def self.spam_detection_instance
      @spam_detection_instance ||= spam_detection_service.constantize.new
    end

    def self.spam_detection_registry
      @spam_detection ||= Decidim::Ai::StrategyRegistry.new
    end

    def self.create_reporting_users!
      Decidim::Organization.find_each do |organization|
        user = organization.users.find_or_initialize_by(email: Decidim::Ai.reporting_user_email)
        next if user.persisted?

        password = SecureRandom.hex(10)
        user.password = password
        user.password_confirmation = password
        user.deleted_at = Time.current
        user.tos_agreement = true
        user.name = ""
        user.skip_confirmation!
        user.save!
      end
    end
  end
end

# frozen_string_literal: true

require "classifier-reborn"
require "cld"
require "decidim/ai/admin"
require "decidim/ai/engine"
require "decidim/ai/admin_engine"
require "decidim/ai/spam_content"
require "decidim/ai/resource"
require "decidim/ai/overrides"

module Decidim
  # This namespace holds the logic of the `Tools::Ai` module. This module
  # allows admins to perform various Artificial Inteligence activities like
  # spam detection.
  module Ai
    include ActiveSupport::Configurable

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

    # This is the email address used by the spam engine to
    # properly identify the user that will report users and content
    config_accessor :reporting_user_email do
      "reporting.user@domain.tld"
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

    def self.create_reporting_users
      Decidim::Organization.find_each do |organization|
        user = Decidim::User.new
        user.organization = organization
        user.email = Decidim::Ai.reporting_user_email
        user.deleted_at = Time.current
        password = SecureRandom.hex(10)
        user.password = password
        user.password_confirmation = password
        user.tos_agreement = true
        user.name = ""
        user.skip_confirmation!
        user.save!
      end
    end
  end
end

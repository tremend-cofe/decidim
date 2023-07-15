# Decidim::Tools-ai

.

## Usage

The Decidim::Tools::AI is a library that aims to privide Artificial Inteligence tools for Decidim. This plugin has been initially developed aiming to analyze the content and provide spam classification using Naive Bayes algorithm.
All AI related functionality provided by Decidim should be included in this same module.

## Installation

In order to install use this library, you need at least Decidim 0.25 to be installed.

Add this line to your application's Gemfile:

```ruby
gem "decidim-tools-ai"
```

And then execute:

```bash
bundle install
```

After that, add an initializer file inside your project, having the following content:

```ruby
# config/initializers/decidim_ai.rb

if defined?(Decidim::Tools::Ai)
  Decidim::Tools::Ai.configure do |config|
    # This is the email address used by user that is going to report the content
    config.reporting_user_email = "aaa.reporting.user@domain.tld"
    # those are the available models that can be used for training
    config.trained_models = %w(
          Decidim::Comments::Comment
          Decidim::Meetings::Meeting
          Decidim::Proposals::Proposal
          Decidim::Proposals::CollaborativeDraft
          Decidim::Debates::Debate
          Decidim::UserBaseEntity
        )
    config.spam_treshold = 0.5
    # We can enable the events override if we are using decidim versions lower than 0.28
    config.enable_override = false
    # Use the supplied vendor data to train the spam engine.
    config.load_vendor_data = true
    #  For small installations (1 vm), you can use memory. Otherwise, use the redis config (with the below config)
    config.backend = :memory # :redis
    config.redis_configuration = {
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
    }
    # you can configure the settings in classifier reborn
    config.spam_classifier_options = {
      #   language:         'en'  # Used to select language specific stop words
      #   auto_categorize:  false # When true, enables ability to dynamically declare a category; the default is true if no initial categories are provided
      #   enable_threshold: false # When true, enables a threshold requirement for classifition
      #   threshold:        0.0   # Default threshold, only used when enabled
      #   enable_stemmer:   true  # When false, disables word stemming
      #   stopwords:        nil   # Accepts path to a text file or an array of words, when supplied, overwrites the default list; assign empty string or array to disable stopwords
    }
  end
end
```

After the configuration is added, you need to run the below command, so that the reporting user is created.

```ruby
bundle exec rake decidim:spam:data:create_reporting_user
```

If you have an existing installation, you can use the below command to train the engine with your existing data:

```ruby
bundle exec rake decidim:spam:train:moderation
```

Add the queue name to `config/sidekiq.yml` file:

```yaml
:queues:
- ["default", 1]
- ["spam_analysis", 1]
# The other yaml entries
```

## Contributing

See [Decidim](https://github.com/decidim/decidim).

## License

This engine is distributed under the GNU AFFERO GENERAL PUBLIC LICENSE.

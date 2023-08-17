# frozen_string_literal: true

require "bundler"
require "rails/generators"
require "rails/generators/rails/app/app_generator"
require "decidim/generators"
require_relative "install_generator"

module Decidim
  module Generators
    class AppBuilder < Rails::AppBuilder
      def readme
        template "README.md.erb", "README.md", force: true
      end

      def database_yml
        template "database.yml.erb", "config/database.yml"
      end

      def production_environment
        gsub_file "config/environments/production.rb",
                  /config.log_level = :info/,
                  "config.log_level = %w(debug info warn error fatal).include?(ENV['RAILS_LOG_LEVEL']) ? ENV['RAILS_LOG_LEVEL'] : :info"

        gsub_file "config/environments/production.rb",
                  %r{# config.asset_host = 'http://assets.example.com'},
                  "config.asset_host = ENV['RAILS_ASSET_HOST'] if ENV['RAILS_ASSET_HOST'].present?"

        gsub_file "config/environments/production.rb",
                  /config.active_storage.service = :local/,
                  "config.active_storage.service = Rails.application.secrets.dig(:storage, :provider) || :local"

        gsub_file "config/environments/production.rb",
                  /# config.active_job.queue_adapter     = :resque/,
                  'config.active_job.queue_adapter = ENV.fetch("QUEUE_ADAPTER", "async").to_sym'
      end

      def development_environment
        gsub_file "config/environments/development.rb", /^end\n$/, <<~CONFIG

            # Performance configs for local testing
            if ENV.fetch("RAILS_BOOST_PERFORMANCE", false).to_s == "true"
              # Indicate boost performance mode
              config.boost_performance = true
              # Enable caching and eager load
              config.eager_load = true
              config.cache_classes = true
              # Logging
              config.log_level = :info
              config.action_view.logger = nil
              # Compress the HTML responses with gzip
              config.middleware.use Rack::Deflater
            end
          end
        CONFIG
      end

      def public_directory
        directory "public", "public", recursive: false

        remove_file "public/404.html"
        remove_file "public/500.html"
        remove_file "public/favicon.ico"
      end

      def leftovers
        copy_file ".rubocop.yml", ".rubocop.yml"
        copy_file ".node-version", ".node-version"

        template "LICENSE-AGPLv3.txt", "LICENSE-AGPLv3.txt"
        template "Dockerfile.erb", "Dockerfile"
        template "docker-compose.yml.erb", "docker-compose.yml"
        template "docker-compose-etherpad.yml", "docker-compose-etherpad.yml"

        template "decidim_controller.rb.erb", "app/controllers/decidim_controller.rb"

        template "initializer.rb.erb", "config/initializers/decidim.rb"
        copy_file "initializers_content_security_policy.rb", "config/initializers/content_security_policy.rb", force: true

        prepend_to_file "config/spring.rb", "require \"decidim/spring\"\n\n" if File.exist?("config/spring.rb")
      end

      def queue_sidekiq_files
        template "sidekiq.yml.erb", "config/sidekiq.yml"

        prepend_file "config/routes.rb", "require \"sidekiq/web\"\n\n"
        route <<~RUBY
          authenticate :user, ->(u) { u.admin? } do
            mount Sidekiq::Web => "/sidekiq"
          end
        RUBY
      end

      def authorization_handler
        copy_file "dummy_authorization_handler.rb", "app/services/dummy_authorization_handler.rb"
        copy_file "another_dummy_authorization_handler.rb", "app/services/another_dummy_authorization_handler.rb"
        copy_file "verifications_initializer.rb", "config/initializers/decidim_verifications.rb"
      end

      def budgets_workflows
        copy_file "budgets_workflow_random.rb", "lib/budgets_workflow_random.rb"
        copy_file "budgets_workflow_random.en.yml", "config/locales/budgets_workflow_random.en.yml"
        copy_file "budgets_initializer.rb", "config/initializers/decidim_budgets.rb"
      end
    end

    # Generates a Rails app and installs decidim to it. Uses the default Rails
    # generator for most of the work.
    #
    # Remember that, for how generators work, actions are executed based on the
    # definition order of the public methods.
    class AppGenerator < Rails::Generators::AppGenerator
      hide!

      def source_paths
        [
          self.class.source_root,
          Rails::Generators::AppGenerator.source_root
        ]
      end

      source_root File.expand_path("app_templates", __dir__)

      class_option :app_name, type: :string,
                              default: nil,
                              desc: "The name of the app"

      class_option :path, type: :string,
                          default: nil,
                          desc: "Path to the gem"

      class_option :edge, type: :boolean,
                          default: false,
                          desc: "Use GitHub's edge version from develop branch"

      class_option :branch, type: :string,
                            default: nil,
                            desc: "Use a specific branch from GitHub's version"

      class_option :repository, type: :string,
                                default: "https://github.com/decidim/decidim.git",
                                desc: "Use a specific GIT repository (valid in conjunction with --edge or --branch)"

      class_option :recreate_db, type: :boolean,
                                 default: false,
                                 desc: "Recreate test database"

      class_option :seed_db, type: :boolean,
                             default: false,
                             desc: "Seed test database"

      class_option :skip_gemfile, type: :boolean,
                                  default: false,
                                  desc: "Do not generate a Gemfile for the application"

      class_option :demo, type: :boolean,
                          default: false,
                          desc: "Generate demo authorization handlers"

      class_option :profiling, type: :boolean,
                               default: false,
                               desc: "Add the necessary gems to profile the app"

      class_option :force_ssl, type: :string,
                               default: "true",
                               desc: "Does not force to use ssl"

      class_option :locales, type: :string,
                             default: "",
                             desc: "Force the available locales to the ones specified. Separate with comas"

      class_option :storage, type: :string,
                             default: "local",
                             desc: "Setup the Gemfile with the appropiate gem to handle a storage provider. Supported options are: local (default), s3, gcs, azure"

      class_option :queue, type: :string,
                           default: "",
                           desc: "Setup the Gemfile with the appropiate gem to handle a queue adapter provider. Supported options are: (empty, does nothing) and sidekiq"

      class_option :dev_ssl, type: :boolean,
                             default: false,
                             desc: "Do not add Puma development SSL configuration options"
      STORAGE_PROVIDERS = %w(local s3 gcs azure).freeze

      def initialize(*args)
        super

        self.options = options.merge(
          database: :postgresql,
          skip_webpack_install: true,
          skip_bundle: true # this is to avoid installing gems in this step yet (done by InstallGenerator)
        )

        providers = options[:storage].split(",")

        abort("#{providers} is not supported as storage provider, please use local, s3, gcs or azure") unless (providers - STORAGE_PROVIDERS).empty?

        abort("#{options[:queue]} is not supported as a queue adapter, please use sidekiq for the moment") unless ["", "sidekiq"].include?(options[:queue])
      end

      def add_queue_adapter_gems
        @extra_entries << GemfileEntry.new("sidekiq", nil, "Sidekiq background processing support", {}, options[:queue] != "sidekiq")
      end

      def add_storage_provider_gems
        providers = options[:storage].split(",")

        @extra_entries << GemfileEntry.new("aws-sdk-s3", nil, "AWS S3 Active Storage support",
                                           { require: false }, providers.exclude?("s3"))
        @extra_entries << GemfileEntry.new("azure-storage-blob", nil, "Azure Active Storage support",
                                           { require: false }, providers.exclude?("azure"))
        @extra_entries << GemfileEntry.new("google-cloud-storage", "~> 1.11", "Google Cloud Platform Active Storage support",
                                           { require: false }, providers.exclude?("gcs"))
      end

      def create_queue_files
        build(:queue_sidekiq_files) if options[:queue] == "sidekiq"
      end

      def build_demo_files
        return unless options[:demo]

        build(:authorization_handler)
        build(:budgets_workflows)
      end

      def setup_production_environment
        build(:production_environment)
      end

      def setup_development_environment
        build(:development_environment)
      end

      # we disable the webpacker installation as we will use shakapacker
      def webpacker_gemfile_entry
        []
      end

      def gemfile
        return if options[:skip_gemfile]

        if branch.present?
          get target_gemfile, "Gemfile", force: true
          append_file "Gemfile", %(\ngem "net-imap", "~> 0.2.3", group: :development)
          append_file "Gemfile", %(\ngem "net-pop", "~> 0.1.1", group: :development)
          append_file "Gemfile", %(\ngem "net-smtp", "~> 0.3.1", group: :development)
          get "#{target_gemfile}.lock", "Gemfile.lock", force: true
        else
          copy_file target_gemfile, "Gemfile", force: true
          copy_file "#{target_gemfile}.lock", "Gemfile.lock", force: true
        end

        gsub_file "Gemfile", /gem "#{current_gem}".*/, "gem \"#{current_gem}\", #{gem_modifier}"

        return unless current_gem == "decidim"

        gsub_file "Gemfile", /gem "decidim-dev".*/, "gem \"decidim-dev\", #{gem_modifier}"

        %w(conferences elections initiatives templates).each do |component|
          if options[:demo]
            gsub_file "Gemfile", /gem "decidim-#{component}".*/, "gem \"decidim-#{component}\", #{gem_modifier}"
          else
            gsub_file "Gemfile", /gem "decidim-#{component}".*/, "# gem \"decidim-#{component}\", #{gem_modifier}"
          end
        end
      end

      def install
        Decidim::Generators::InstallGenerator.start(
          [
            "--recreate_db=#{options[:recreate_db]}",
            "--seed_db=#{options[:seed_db]}",
            "--skip_gemfile=#{options[:skip_gemfile]}",
            "--app_name=#{app_name}",
            "--profiling=#{options[:profiling]}"
          ]
        )
      end

      private

      # rubocop:disable Naming/AccessorMethodName
      def get_builder_class
        Decidim::Generators::AppBuilder
      end
      # rubocop:enable Naming/AccessorMethodName

      # old

      def gem_modifier
        @gem_modifier ||= if options[:path]
                            %(path: "#{options[:path]}")
                          elsif branch.present?
                            %(git: "#{repository}", branch: "#{branch}")
                          else
                            %("#{Decidim::Generators.version}")
                          end
      end

      def branch
        return if options[:path]

        @branch ||= options[:edge] ? Decidim::Generators.edge_git_branch : options[:branch].presence
      end

      def repository
        @repository ||= options[:repository] || "https://github.com/decidim/decidim.git"
      end

      def app_name
        options[:app_name] || super
      end

      def app_const_base
        app_name.gsub(/\W/, "_").squeeze("_").camelize
      end

      def current_gem
        return "decidim" unless options[:path]

        @current_gem ||= File.read(gemspec).match(/name\s*=\s*['"](?<name>.*)["']/)[:name]
      end

      def gemspec
        File.expand_path(Dir.glob("*.gemspec", base: expanded_path).first, expanded_path)
      end

      def target_gemfile
        root = if options[:path]
                 expanded_path
               elsif branch.present?
                 "https://raw.githubusercontent.com/decidim/decidim/#{branch}/decidim-generators"
               else
                 root_path
               end

        File.join(root, "Gemfile")
      end

      def expanded_path
        File.expand_path(options[:path])
      end

      def root_path
        File.expand_path(File.join("..", "..", ".."), __dir__)
      end
    end
  end
end

# frozen_string_literal: true

require "rails/generators/base"
require "securerandom"

module Decidim
  module Generators
    # Installs `decidim` to a Rails app by adding the needed lines of code
    # automatically to important files in the Rails app.
    #
    # Remember that, for how generators work, actions are executed based on the
    # definition order of the public methods.
    class InstallGenerator < Rails::Generators::Base
      desc "Install decidim"
      source_root File.expand_path("app_templates", __dir__)

      class_option :app_name, type: :string,
                              default: nil,
                              desc: "The name of the app"

      class_option :recreate_db, type: :boolean,
                                 default: false,
                                 desc: "Recreate db after installing decidim"

      class_option :seed_db, type: :boolean,
                             default: false,
                             desc: "Seed db after installing decidim"

      class_option :skip_gemfile, type: :boolean,
                                  default: false,
                                  desc: "Do not generate a Gemfile for the application"

      class_option :profiling, type: :boolean,
                               default: false,
                               desc: "Add the necessary gems to profile the app"

      def bundle_install
        run "bundle install"
      end

      private

      def recreate_db
        soft_rails "db:environment:set", "db:drop"
        rails "db:create"

        rails "db:migrate"

        rails "db:seed" if options[:seed_db]

        rails "db:test:prepare"
      end

      # Runs rails commands in a subprocess, and aborts if it does not suceeed
      def rails(*args)
        abort unless system("bin/rails", *args)
      end

      # Runs rails commands in a subprocess silencing errors, and ignores status
      def soft_rails(*args)
        system("bin/rails", *args, err: File::NULL)
      end

      def cut(text, strip: true)
        cutted = text.gsub(/^ *\|/, "")
        return cutted unless strip

        cutted.rstrip
      end
    end
  end
end

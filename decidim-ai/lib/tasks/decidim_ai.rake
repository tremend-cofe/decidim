# frozen_string_literal: true

namespace :decidim do
  namespace :ai do
    desc "Create reporting user"
    task create_reporting_user: :environment do
      Decidim::Ai.create_reporting_users!
    end
  end

  namespace :spam do
    desc "Reset the whole spam detection algorithm"
    task reset: :environment do
      Decidim::Ai::SpamContent::Repository.reset!
    end

    namespace :train do
      desc "Train Antispam algorithm using the curent exisisting data from database and gem's data folder"
      task moderation: :environment do
        Decidim::Ai::SpamContent::Repository.train!
      end

      desc "Train spam detection filter using a custom file "
      task :file, [:file] do |_, args|
        Decidim::Ai::SpamContent::Repository.load_from_file!(Rails.root, args[:file])
      end
    end

    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_tools_ai"
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:spam:choose_target_plugins"].invoke
end

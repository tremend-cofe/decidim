# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Anti-spam
    # This is the engine that runs on the public interface of anti-spam.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Anti-spam

      routes do
        # Add engine routes here
        # resources :anti-spam
        # root to: "anti-spam#index"
      end

      initializer "decidim_anti-spam.assets" do |app|
        app.config.assets.precompile += %w[decidim_anti-spam_manifest.js decidim_anti-spam_manifest.css]
      end
    end
  end
end

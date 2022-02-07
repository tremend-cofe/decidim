# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Templates
    # This is the engine that runs on the public interface of templates.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Templates

      routes do
        # Add engine routes here
        resources :templates
        # root to: "templates#index"
      end

      initializer "decidim_templates.webpacker.assets_path" do
        Decidim.register_assets_path File.expand_path("app/packs", root)
      end

      initializer "decidim_templates.importmap", before: "importmap" do |app|
        app.config.importmap.paths << Engine.root.join("config/importmap.rb")
        app.config.importmap.cache_sweepers << Engine.root.join("app/packs/src")
      end

      initializer "decidim_templates.importmap.assets", before: "importmap.assets" do |app|
        app.config.assets.paths << Engine.root.join("app/packs") if app.config.respond_to?(:assets)
      end
    end
  end
end

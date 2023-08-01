# frozen_string_literal: true

module Decidim
  module Ai
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Ai::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :forbidden_keywords
        resources :stopwords
        root to: "forbidden_keywords#index"
      end

      initializer "decidim_tools_ai.admin_mount_routes" do
        Decidim::Core::Engine.routes do
          mount Decidim::Ai::AdminEngine, at: "/admin/ai", as: "decidim_admin_ai_tools"
        end
      end

      initializer "decidim_tools_ai.admin_participatory_processes_menu" do
        Decidim.menu :admin_tools_ai_menu do |menu|
          menu.add_item :forbidden_keywords,
                        I18n.t("menu.forbidden_keywords", scope: "decidim.admin"),
                        decidim_admin_ai_tools.forbidden_keywords_path,
                        position: 1,
                        if: allowed_to?(:index, :tools_ai),
                        active: is_active_link?(decidim_admin_ai_tools.forbidden_keywords_path)
          menu.add_item :stopwords,
                        I18n.t("menu.stopwords", scope: "decidim.admin"),
                        decidim_admin_ai_tools.stopwords_path,
                        position: 2,
                        if: allowed_to?(:index, :tools_ai),
                        active: is_active_link?(decidim_admin_ai_tools.stopwords_path)
        end
      end

      initializer "decidim_tools_ai.admin_menu" do
        Decidim.menu :admin_menu do |menu|
          menu.add_item :tools_ai,
                        I18n.t("menu.ai_tools", scope: "decidim.admin"),
                        decidim_admin_ai_tools.forbidden_keywords_path,
                        icon_name: "globe",
                        position: 13,
                        active: :inclusive,
                        if: allowed_to?(:read, :tools_ai)
        end
      end

      def load_seed
        nil
      end
    end
  end
end

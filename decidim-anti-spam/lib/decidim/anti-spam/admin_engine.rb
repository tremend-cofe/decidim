# frozen_string_literal: true

module Decidim
  module AntiSpam
    # This is the engine that runs on the public interface of `Anti-spam`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Anti-spam::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        # Add admin engine routes here
        # resources :anti-spam do
        #   collection do
        #     resources :exports, only: [:create]
        #   end
        # end
        # root to: "anti-spam#index"
      end

      def load_seed
        nil
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Budgets
    module Admin
      # This command is executed when the user deletes a Project from the admin
      # panel.
      class DestroyProject < Decidim::Commands::DestroyResource
      end
    end
  end
end

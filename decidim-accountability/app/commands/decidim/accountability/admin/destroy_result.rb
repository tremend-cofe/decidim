# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user destroys a Result from the admin
      # panel.
      class DestroyResult < Decidim::Commands::DestroyResource
      end
    end
  end
end

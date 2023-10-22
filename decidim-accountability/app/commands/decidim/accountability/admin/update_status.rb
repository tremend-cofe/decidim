# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateStatus < Decidim::Commands::UpdateResource
        fetch_form_attributes :key, :name, :description, :progress

        # Initializes an UpdateStatus Command.
        #
        # form - The form from which to get the data.
        # status - The current instance of the status to be updated.
        def initialize(form, status, _user)
          super(form, status)
        end
      end
    end
  end
end

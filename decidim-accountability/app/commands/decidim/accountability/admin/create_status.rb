# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Status from the admin
      # panel.
      class CreateStatus < Decidim::Commands::CreateResource
        fetch_form_attributes :key, :name, :description, :progress
        def initialize(form, _user)
          super(form)
        end

        private

        def resource_class = Decidim::Accountability::Status

        def attributes = super.merge(component: form.current_component)
      end
    end
  end
end

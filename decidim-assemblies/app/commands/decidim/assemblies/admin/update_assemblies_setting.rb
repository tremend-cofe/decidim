# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating assemblies
      # settings in admin area.
      class UpdateAssembliesSetting < Decidim::Commands::UpdateResource
        fetch_form_attributes :enable_organization_chart
        # Public: Initializes the command.
        #
        # assemblies_setting - A assemblies_setting object to update.
        # form - A form object with the params.
        def initialize(assemblies_settings, form)
          super(form, assemblies_settings)
        end

        protected

        def invalid?
          form.invalid? || resource.invalid?
        end
      end
    end
  end
end

# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating a new assembly
      # type in the system.
      class UpdateAssembliesType < Decidim::Commands::UpdateResource
        fetch_form_attributes :title

        # Public: Initializes the command.
        #
        # assemblies_type - A assemblies_type object to update.
        # form - A form object with the params.
        def initialize(assemblies_type, form)
          super(form, assemblies_type)
        end
      end
    end
  end
end

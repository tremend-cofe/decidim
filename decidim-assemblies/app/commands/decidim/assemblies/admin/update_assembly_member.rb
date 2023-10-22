# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # A command with all the business logic when updating an assembly
      # member in the system.
      class UpdateAssemblyMember < Decidim::Commands::UpdateResource
        include ::Decidim::AttachmentAttributesMethods

        fetch_form_attributes :full_name, :gender, :birthday, :birthplace, :ceased_date, :designation_date,
                              :position, :position_other

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?
          return broadcast(:invalid) unless resource

          update_resource
          broadcast(:ok)
        rescue ActiveRecord::RecordInvalid
          if resource.errors.include? :non_user_avatar
            form.errors.add(
              :non_user_avatar,
              resource.errors[:non_user_avatar]
            )
          end

          broadcast(:invalid)
        end

        private

        def attributes
          super.merge(user: form.user).merge(attachment_attributes(:non_user_avatar))
        end

        def extra_params
          {
            resource: {
              title: resource.full_name
            },
            participatory_space: {
              title: resource.assembly.title
            }
          }
        end
      end
    end
  end
end

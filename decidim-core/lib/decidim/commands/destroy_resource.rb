# frozen_string_literal: true

module Decidim
  module Commands
    class DestroyResource < ::Decidim::Command
      def initialize(resource, current_user)
        @resource = resource
        @current_user = current_user
      end

      # Destroys the result.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        destroy_resource

        broadcast(:ok, resource)
      end

      private

      attr_reader :resource, :current_user

      def invalid? = false

      def destroy_resource
        Decidim.traceability.perform_action!(
          :delete,
          resource,
          current_user,
          **extra_params
        ) do
          resource.destroy!
        end
      end

      def extra_params = {}
    end
  end
end

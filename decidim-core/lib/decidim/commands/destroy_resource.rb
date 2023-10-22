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
        destroy_resource

        broadcast(:ok)
      end

      private

      attr_reader :resource, :current_user

      def destroy_resource
        Decidim.traceability.perform_action!(
          :delete,
          resource,
          current_user
        ) do
          resource.destroy!
        end
      end
    end
  end
end

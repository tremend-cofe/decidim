# frozen_string_literal: true

module Decidim
  module Commands
    class CreateResource < ::Decidim::Command
      include Decidim::Commands::ResourceHandler
      def initialize(form)
        @form = form
      end

      # Creates the result if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        transaction do
          create_resource
        end

        broadcast(:ok, resource)
      end

      def create_resource(soft: false)
        @resource = Decidim.traceability.send(soft ? :create : :create!,
                                              resource_class,
                                              form.current_user,
                                              attributes,
                                              **extra_params)
      end

      private

      attr_reader :form, :resource
    end
  end
end

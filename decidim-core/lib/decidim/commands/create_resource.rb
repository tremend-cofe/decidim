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
          run_before_hooks
          create_resource
          run_after_hooks
        end

        broadcast(:ok, resource)
      rescue Decidim::Commands::HookError, ActiveRecord::ActiveRecordError
        broadcast(:invalid)
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

      def run_before_hooks; end

      def run_after_hooks; end
    end
  end
end

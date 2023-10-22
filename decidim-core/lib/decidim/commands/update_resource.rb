# frozen_string_literal: true

module Decidim
  module Commands
    class UpdateResource < ::Decidim::Command
      def initialize(form, resource)
        @form = form
        @resource = resource
      end

      # Updates the timeline_entry if valid.
      #
      # Broadcasts :ok if successful, :invalid otherwise.
      def call
        return broadcast(:invalid) if invalid?

        transaction do
          update_resource
        end

        broadcast(:ok)
      end

      def self.fetch_form_attributes(*fields)
        define_method(:form_attributes) do
          fields
        end
      end

      protected

      attr_reader :form, :resource

      def invalid?
        form.invalid?
      end

      def update_resource
        Decidim.traceability.update!(
          resource,
          form.current_user,
          attributes,
          **extra_params
        )
      end

      def attributes
        raise "You need to define the list of attributes to be fetched from form object fetch_form_attributes" unless defined?(:form_attributes)

        @attributes ||= form_attributes.index_with do |field|
          form.send(field)
        end
      end

      def extra_params = {}
    end
  end
end

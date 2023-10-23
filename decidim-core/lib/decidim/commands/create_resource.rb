# frozen_string_literal: true

module Decidim
  module Commands
    class CreateResource < ::Decidim::Command
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

      def self.fetch_form_attributes(*fields)
        define_method(:form_attributes) do
          fields
        end
      end

      private

      attr_reader :form, :resource

      def invalid?
        form.invalid?
      end
      
      def resource_class = raise "#{self.class.name} needs to implement #{__method__}"

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

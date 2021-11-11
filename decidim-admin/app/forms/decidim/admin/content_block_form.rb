# frozen_string_literal: true

module Decidim
  module Admin
    # A form object used to configure a content block from the admin panel.
    #
    class ContentBlockForm < Decidim::Form
      include TranslatableAttributes

      mimic :content_block

      attribute :settings, Object
      attribute :images, Hash

      def map_model(model)
        self.images = model.images_container
      end

      def settings?
        settings.manifest.settings.any?
      end

      private
      def errors
        super.merge!(settings.errors)
        raise super.inspect
      end
      # def valid?(options = {})
      #   super
      #   raise settings.errors.inspect
      # end
      # def form_attributes_valid?
      #   return false unless errors.empty? && settings_errors_empty? # Preserves errors from custom validation methods
      #
      #   attributes_that_respond_to(:valid?).all?(&:valid?)
      # end
      #
      # def settings_errors_empty?
      #   raise settings.evalid?.inspect
      #   # validations = [settings.errors.empty?]
      #
      #   validations.all?
      # end

      # def before_validation
      #   _validators.reverse_merge! settings.manifest.schema._validators
      # end
    end
  end
end

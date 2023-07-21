# frozen_string_literal: true

module Decidim
  module Ai
    class TrainHiddenResourceDataJob < ApplicationJob
      include Decidim::TranslatableAttributes

      def perform(resource)
        return unless resource.respond_to?(:hidden?)

        resource.reload
        spam_backend = Decidim::Ai.spam_detection_service.constantize.new(resource.organization)

        wrapped = Decidim::Ai::Resource::Wrapper.new(resource.class)

        if resource.hidden?
          wrapped.fields.each do |field|
            spam_backend.untrain "normal", translated_attribute(resource.send(field))
            spam_backend.train "spam", translated_attribute(resource.send(field))
          end
        end
      end
    end
  end
end

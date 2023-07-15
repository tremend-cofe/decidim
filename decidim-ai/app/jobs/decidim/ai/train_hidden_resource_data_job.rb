# frozen_string_literal: true

module Decidim
  module Ai
    class TrainHiddenResourceDataJob < ApplicationJob
      include Decidim::TranslatableAttributes

      def perform(resource, spam_backend = Decidim::Ai::SpamContent::Repository.new)
        return unless resource.respond_to?(:hidden?)

        resource.reload

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

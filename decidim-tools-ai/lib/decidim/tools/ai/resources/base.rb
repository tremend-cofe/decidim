# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Resource
        class Base
          include Decidim::TranslatableAttributes
          def add_training_data!(classifier)
            query.find_each(batch_size: 100) do |resource|
              category = resource_hidden?(resource) ? "spam" : "normal"

              fields.each do |field_name|
                classifier.train category, translated_attribute(resource.send(field_name))
              end
            end
          end

          protected

          def resource_hidden?(resource)
            resource.class.included_modules.include?(Decidim::Reportable) && resource.hidden?
          end
        end
      end
    end
  end
end

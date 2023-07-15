# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Resource
        class UserBaseEntity < Base
          def add_training_data!(classifier)
            query.find_each(batch_size: 100) do |resource|
              category = resource_hidden?(resource) ? "spam" : "normal"
              fields.each do |field_name|
                classifier.train category, resource.send(field_name)
              end
            end
          end

          def fields
            [:about]
          end

          def query
            Decidim::UserBaseEntity.includes(:user_moderation)
          end

          def resource_hidden?(resource)
            resource.class.included_modules.include?(Decidim::UserReportable) && resource.blocked?
          end
        end
      end
    end
  end
end

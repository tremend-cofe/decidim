# frozen_string_literal: true

module Decidim
  module Ai
    module SpamDetection
      module Resource
        class UserBaseEntity < Base
          def fields = [:about]

          def batch_train
            query.find_each(batch_size: 100) do |resource|
              category = resource_hidden?(resource) ? :spam : :ham
              fields.each do |field_name|
                classifier.train category, resource.send(field_name)
              end
            end
          end

          protected

          def query = Decidim::UserBaseEntity.includes(:user_moderation)

          def resource_hidden?(resource)
            resource.class.included_modules.include?(Decidim::UserReportable) && resource.blocked?
          end
        end
      end
    end
  end
end

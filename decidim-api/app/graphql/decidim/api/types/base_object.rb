module Decidim
  module Api
    module Types
      class BaseObject < GraphQL::Schema::Object
        field_class Types::BaseField

        def initialize(object, context)
          Rails.logger.info("#{name} was initialized")
          super
        end

      end
    end
  end
end

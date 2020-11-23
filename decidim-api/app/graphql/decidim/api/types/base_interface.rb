module Decidim
  module Api
    module Types
      module BaseInterface
        include GraphQL::Schema::Interface

        field_class Types::BaseField


        def self.resolve_type(obj:, ctx:)
          Rails.logger.info(obj.inspect)
          super
        end
      end
    end
  end
end

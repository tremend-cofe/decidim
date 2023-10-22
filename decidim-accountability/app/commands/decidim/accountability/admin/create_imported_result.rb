# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user creates a Result from the admin
      # panel.
      class CreateImportedResult < CreateResult
        def initialize(form, parent_id = nil)
          super(form)
          @parent_id = parent_id
        end

        private

        def attributes
          super.merge(parent_id: @parent_id)
        end
      end
    end
  end
end

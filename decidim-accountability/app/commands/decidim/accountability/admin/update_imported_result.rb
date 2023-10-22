# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateImportedResult < UpdateResult
        # Initializes an UpdateResult Command.
        #
        # form - The form from which to get the data.
        # result - The current instance of the result to be updated.
        def initialize(form, result, parent_id = nil)
          super(form, result)
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

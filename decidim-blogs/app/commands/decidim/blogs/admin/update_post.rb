# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user changes a Blog from the admin
      # panel.
      class UpdatePost < Decidim::Commands::UpdateResource
        fetch_form_attributes :title, :body, :author

        # Initializes a UpdateBlog Command.
        #
        # form - The form from which to get the data.
        # blog - The current instance of the page to be updated.
        def initialize(form, post, _user)
          super(form, post)
        end

        private

        def attributes
          super.merge(published_at: form.published_at).reject do |attribute, value|
            value.blank? && attribute == :published_at
          end
        end
      end
    end
  end
end

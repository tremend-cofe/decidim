# frozen_string_literal: true

module Decidim
  module Blogs
    module Admin
      # This command is executed when the user creates a Post from the admin
      # panel.
      class CreatePost < Decidim::Commands::CreateResource
        fetch_form_attributes :title, :body, :published_at, :author, :component

        def initialize(form, _current_user)
          super(form)
        end

        private

        attr_reader :form

        def create_resource(soft: false)
          super
          send_notification
        end

        def resource_class = Decidim::Blogs::Post

        def extra_params = { visibility: "all" }

        def send_notification
          Decidim::EventsManager.publish(
            event: "decidim.events.blogs.post_created",
            event_class: Decidim::Blogs::CreatePostEvent,
            resource:,
            followers: resource.participatory_space.followers
          )
        end
      end
    end
  end
end

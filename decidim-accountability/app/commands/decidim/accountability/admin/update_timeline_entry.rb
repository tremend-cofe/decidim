# frozen_string_literal: true

module Decidim
  module Accountability
    module Admin
      # This command is executed when the user changes a Result from the admin
      # panel.
      class UpdateTimelineEntry < Decidim::Commands::UpdateResource
        fetch_form_attributes :entry_date, :title, :description

        # Initializes an UpdateTimelineEntry Command.
        #
        # form - The form from which to get the data.
        # timeline_entry - The current instance of the timeline_entry to be updated.
        def initialize(form, timeline_entry, _user)
          super(form, timeline_entry)
        end
      end
    end
  end
end

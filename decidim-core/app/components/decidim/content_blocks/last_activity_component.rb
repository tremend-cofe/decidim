# frozen_string_literal: true

class Decidim::ContentBlocks::LastActivityComponent < Decidim::ContentBlocks::BaseComponent
  include Decidim::Core::Engine.routes.url_helpers

  def render? = valid_activities.any?

  attr_reader :content_block, :options

  # The activities to be displayed at the content block.
  #
  # We need to build the collection this way because an ActionLog has
  # polymorphic relations to different kind of models, and these models
  # might not be available (a proposal might have been hidden or withdrawn).
  #
  # Since these conditions cannot always be filtered with a database search
  # we ask for more activities than we actually need and then loop until there
  # are enough of them.
  #
  # Returns an Array of ActionLogs.
  def valid_activities
    return @valid_activities if defined?(@valid_activities)

    valid_activities_count = 0
    @valid_activities = []

    activities.includes([:user]).each do |activity|
      break if valid_activities_count == activities_to_show

      if activity.visible_for?(current_user)
        @valid_activities << activity
        valid_activities_count += 1
      end
    end

    @valid_activities
  end

  def activities = @activities ||= Decidim::LastActivity.new(organization, current_user:).query.limit(activities_to_show * 6)

  def activities_to_show = 8
end

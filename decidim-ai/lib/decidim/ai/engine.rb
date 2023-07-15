# frozen_string_literal: true

module Decidim
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Ai

      initializer "decidim_tools_ai.subscribe_profile_events" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.events\.users\.profile_updated$/) do |_event_name, data|
            Decidim::Ai::UserSpamAnalyzerJob.perform_later(data[:resource])
          end
          Decidim::EventsManager.subscribe(/^decidim\.admin\.block_user:after$/) do |_event_name, data|
            Decidim::Ai::TrainUserDataJob.perform_later(data[:resource])
          end
        end
      end

      initializer "decidim_tools_ai.subscribe_resource_events" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.system\.core\.resource\.hidden:after$/) do |_event_name, data|
            Decidim::Ai::TrainHiddenResourceDataJob.perform_later(data[:resource])
          end
        end
      end

      initializer "decidim_tools_ai.subscribe_comments_events" do
        # TODO: Add debate related events
      end

      initializer "decidim_tools_ai.subscribe_comments_events" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim.comments.create_comment:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body])
          end
          Decidim::EventsManager.subscribe(/^decidim.comments.update_comment:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body])
          end
        end
      end

      initializer "decidim_tools_ai.subscribe_meeting_events" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.meetings\.create_meeting:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title, :location_hints, :registration_terms])
          end
          Decidim::EventsManager.subscribe(/^decidim\.meetings\.update_meeting:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale],
                                                              [:description, :title, :location_hints, :registration_terms, :closing_report])
          end
        end
      end

      initializer "decidim_tools_ai.subscribe_debate_events" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.debates\.create_debate:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title])
          end
          Decidim::EventsManager.subscribe(/^decidim\.debates\.update_debate:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title])
          end
        end
      end

      initializer "decidim_tools_ai.subscribe_proposals_events" do
        config.to_prepare do
          Decidim::EventsManager.subscribe(/^decidim\.proposals\.create_proposal:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
          Decidim::EventsManager.subscribe(/^decidim\.proposals\.update_proposal:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
          Decidim::EventsManager.subscribe(/^decidim\.proposals\.create_collaborative_draft:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
          Decidim::EventsManager.subscribe(/^decidim\.proposals\.update_collaborative_draft:after$/) do |_event_name, data|
            Decidim::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
          end
        end
      end

      def load_seed
        nil
      end
    end
  end
end

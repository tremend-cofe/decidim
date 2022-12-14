# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Tools::Ai

        initializer "decidim_tools_ai.create_overrides" do
          Rails.application.reloader.to_prepare do
            Decidim::Meetings::CreateMeeting.prepend Decidim::Tools::Ai::Overrides::CreateMeeting
            Decidim::Meetings::UpdateMeeting.prepend Decidim::Tools::Ai::Overrides::UpdateMeeting
            Decidim::Comments::CreateComment.prepend Decidim::Tools::Ai::Overrides::CreateComment
            Decidim::Comments::UpdateComment.prepend Decidim::Tools::Ai::Overrides::UpdateComment
            Decidim::Proposals::CreateCollaborativeDraft.prepend Decidim::Tools::Ai::Overrides::CreateCollaborativeDraft
            Decidim::Proposals::UpdateCollaborativeDraft.prepend Decidim::Tools::Ai::Overrides::UpdateCollaborativeDraft
            Decidim::Proposals::CreateProposal.prepend Decidim::Tools::Ai::Overrides::CreateProposal
            Decidim::Proposals::UpdateProposal.prepend Decidim::Tools::Ai::Overrides::UpdateProposal
            Decidim::Admin::BlockUser.prepend Decidim::Tools::Ai::Overrides::BlockUser
          end
        end

        initializer "decidim_tools_ai.subscribe_profile_events" do
          config.to_prepare do
            Decidim::EventsManager.subscribe(/^decidim\.events\.users\.profile_updated$/) do |_event_name, data|
              Decidim::Tools::Ai::UserSpamAnalyzerJob.perform_later(data[:resource])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.core\.user\.blocked$/) do |_event_name, data|
              Decidim::Tools::Ai::TrainUserDataJob.perform_later(data[:resource])
            end
          end
        end

        initializer "decidim_tools_ai.subscribe_resource_events" do
          config.to_prepare do
            Decidim::EventsManager.subscribe(/^decidim\.system\.core\.resource\.hidden$/) do |_event_name, data|
              Decidim::Tools::Ai::TrainHiddenResourceDataJob.perform_later(data[:resource])
            end
          end
        end

        initializer "decidim_tools_ai.subscribe_comments_events" do
          # TODO: Add debate related events
        end
        initializer "decidim_tools_ai.subscribe_comments_events" do
          config.to_prepare do
            Decidim::EventsManager.subscribe(/^decidim\.system\.comments\.comment\.created$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.comments\.comment\.updated$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body])
            end
          end
        end

        initializer "decidim_tools_ai.subscribe_meeting_events" do
          config.to_prepare do
            Decidim::EventsManager.subscribe(/^decidim\.system\.meetings\.meeting\.created$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title, :location_hints, :registration_terms])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.meetings\.meeting\.updated$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale],
                                                                       [:description, :title, :location_hints, :registration_terms, :closing_report])
            end
          end
        end

        initializer "decidim_tools_ai.subscribe_debate_events" do
          config.to_prepare do
            Decidim::EventsManager.subscribe(/^decidim\.system\.debates\.debate\.created$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.debates\.debate\.updated$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:description, :title])
            end
          end
        end

        initializer "decidim_tools_ai.subscribe_proposals_events" do
          config.to_prepare do
            Decidim::EventsManager.subscribe(/^decidim\.system\.proposals\.proposal\.created$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.proposals\.proposal\.updated$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.proposals\.collaborative_draft\.created$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
            end
            Decidim::EventsManager.subscribe(/^decidim\.system\.proposals\.collaborative_draft\.updated$/) do |_event_name, data|
              Decidim::Tools::Ai::GenericSpamAnalyzerJob.perform_later(data[:resource], data[:author], data[:locale], [:body, :title])
            end
          end
        end

        def load_seed
          nil
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tools
    module Ai
      describe GenericSpamAnalyzerJob do
        subject { described_class }

        let!(:system_user) { create(:user, :confirmed, email: Decidim::Tools::Ai.reporting_user_email, organization:) }
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:dummy_component, participatory_space: participatory_process) }
        let(:user) { create(:user, :confirmed, organization:) }

        let(:commentable) { create(:dummy_resource, component:) }

        let(:comment) { create(:comment, commentable:, body: { en: "Claim your prize." }) }

        let!(:normal_comment) { create(:comment, commentable:, body: { en: "This is a very good ideea!" }) }
        let(:reported_comment) { create(:comment, commentable:, body: { en: "You are the lucky winner! Claim your holiday prize." }) }
        let(:moderation) do
          create(:moderation, :hidden, reportable: reported_comment, report_count: 3,
                                       reported_content: reported_comment.reported_searchable_content_text)
        end
        let!(:report) { create(:report, moderation:, user:, reason: "spam") }

        before do
          Decidim::Tools::Ai.backend = :memory
          Decidim::Tools::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
          Decidim::Tools::Ai.load_vendor_data = false
          Decidim::Tools::Ai.trained_models = %w(Decidim::Tools::Ai::Resource::Comment)

          expect(Decidim::Comments::Comment.count).to eq(2)
          Decidim::Tools::Ai::SpamContent::Repository.train!
        end

        it "successfully calls the job" do
          ActiveJob::Base.queue_adapter = :inline
          ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
          expect(Decidim::Report.count).to eq(1)
          subject.perform_now(comment, comment.author, :en, [:body])
          perform_enqueued_jobs
          expect(Decidim::Report.count).to eq(2)
        end
      end
    end
  end
end

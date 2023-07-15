# frozen_string_literal: true

require "spec_helper"

describe "User changes own data", type: :system do
  shared_examples "user content submitted to spam analysis" do
    context "when override is enabled" do
      before do
        Decidim::Ai.enable_override = true
      end

      it "updates the about text" do
        expect { command.call }.to broadcast(:ok)
        field = resource.last.reload.send(compared_field)
        expect(field.is_a?(String) ? field : field[I18n.locale.to_s]).to eq(compared_against)
      end

      it "fires the event" do
        # ActiveJob::Base.queue_adapter = :test
        expect { command.call }.to have_enqueued_job.on_queue("spam_analysis")
                                                    .exactly(queue_size).times
      end
    end

    context "when override is disabled" do
      before do
        Decidim::Ai.enable_override = false
      end

      it "updates the about text" do
        expect { command.call }.to broadcast(:ok)
        field = resource.last.reload.send(compared_field)
        expect(field.is_a?(String) ? field : field[I18n.locale.to_s]).to eq(compared_against)
      end

      it "fires the event" do
        # ActiveJob::Base.queue_adapter = :test
        expect { command.call }.to have_enqueued_job.on_queue("spam_analysis")
                                                    .exactly(queue_size).times
      end

      it "processes the event" do
        # ActiveJob::Base.queue_adapter = :test

        perform_enqueued_jobs do
          expect { command.call }.to change(Decidim::UserReport, :count).by_at_least(spam_count)
          expect(Decidim::UserReport.count).to eq(1 + spam_count)
        end
      end
    end
  end

  let(:data) do
    {
      name: user.name,
      nickname: user.nickname,
      email: user.email,
      password: nil,
      password_confirmation: nil,
      avatar: nil,
      remove_avatar: nil,
      personal_url: "https://example.org",
      about:,
      locale: "es"
    }
  end
  let(:organization) { create(:organization) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }

  let!(:unreported_resource) { create(:user, :confirmed, organization:, about: "This is a very good ideea!") }
  let!(:reported_resource) { create(:user, :blocked, :confirmed, organization:, about: "You are the lucky winner! Claim your holiday prize.") }
  let(:moderation) { create(:user_moderation, user: reported_resource, report_count: 3) }
  let!(:report) { create(:user_report, moderation:, user: system_user, reason: "spam") }

  let(:user) { create(:user, :confirmed, about: "Some description about me, that is not going to be very easily blocked.", organization:) }
  let(:command) { Decidim::UpdateAccount.new(user, form) }

  let(:form) do
    Decidim::AccountForm.from_params(**data).with_context(current_organization: organization, current_user: user)
  end

  before do
    Decidim::Ai.backend = :memory
    Decidim::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
    Decidim::Ai.load_vendor_data = false
    Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::UserBaseEntity)
    Decidim::Ai::SpamContent::Repository.train!
  end

  context "when spam content is added" do
    let(:about) { "Claim your prize today so you can win." }

    include_examples "user content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 1 }
      let(:compared_field) { :about }
      let(:compared_against) { about }
      let(:resource) { Decidim::UserBaseEntity }
    end
  end

  context "when regular content content is added" do
    let(:about) { "Very nice ideea that is not going to be blocked" }

    include_examples "user content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 0 }
      let(:compared_field) { :about }
      let(:compared_against) { about }
      let(:resource) { Decidim::UserBaseEntity }
    end
  end
end

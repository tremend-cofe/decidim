# frozen_string_literal: true

shared_examples "content submitted to spam analysis" do
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
        expect { command.call }.to change(Decidim::Report, :count).by_at_least(spam_count)
        expect(Decidim::Report.count).to eq(1 + spam_count)
      end
    end
  end
end

shared_examples "comments spam analysis" do
  let(:organization) { create(:organization) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process) }
  let(:dummy_resource) { create(:dummy_resource, component:) }
  let(:commentable) { dummy_resource }
  let(:author) { create(:user, organization:) }
  let!(:unreported_resource) { create(:comment, author:, commentable:, body: { en: "This is a very good ideea! " }) }
  let!(:reported_resource) { create(:comment, author:, commentable:, body: { en: "You are the lucky winner! Claim your holiday prize." }) }
  let(:moderation) do
    create(:moderation, :hidden, reportable: reported_resource, report_count: 3,
                                 reported_content: reported_resource.reported_searchable_content_text)
  end
  let!(:report) { create(:report, moderation:, user: system_user, reason: "spam") }
  before do
    Decidim::Ai.backend = :memory
    Decidim::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
    Decidim::Ai.load_vendor_data = false
    Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Comment)
    Decidim::Ai::SpamContent::Repository.train!
  end

  context "when spam content is added" do
    let(:body) { "Claim your prize today so you can win." }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 1 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Comments::Comment }
    end
  end

  context "when regular content content is added" do
    let(:body) { "Very nice ideea that is not going to be blocked by engine" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 0 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Comments::Comment }
    end
  end
end

shared_examples "debates spam analysis" do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:component) { create(:component, participatory_space: participatory_process, manifest_name: "debates") }
  let(:author) { create(:user, organization:) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }
  let(:scope) { create(:scope, organization:) }
  let(:category) { create(:category, participatory_space: participatory_process) }

  let!(:unreported_resource) { create(:debate, component:, author:, title: { en: "This is a very good ideea!" }, description: { en: "This is a very good ideea! " }) }
  let!(:reported_resource) { create(:debate, component:, author:, title: { en: "Winner, Blody Winner" }, description: { en: "You are the lucky winner! Claim your holiday prize." }) }
  let(:moderation) do
    create(:moderation, :hidden, reportable: reported_resource, report_count: 3,
                                 reported_content: reported_resource.reported_searchable_content_text)
  end
  let!(:report) { create(:report, moderation:, user: system_user, reason: "spam") }

  before do
    Decidim::Ai.backend = :memory
    Decidim::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
    Decidim::Ai.load_vendor_data = false
    Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Debate)
    Decidim::Ai::SpamContent::Repository.train!
  end

  context "when spam content is added" do
    let(:description) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 1 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Debates::Debate }
    end
  end

  context "when regular content content is added" do
    let(:description) { "Very nice ideea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 0 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Debates::Debate }
    end
  end
end

shared_examples "meetings spam analysis" do
  let(:organization) { create(:organization, available_locales: [:en]) }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }
  let(:participatory_process) { create(:participatory_process, organization:) }
  let(:author) { create(:user, :admin, :confirmed, organization:) }
  let(:component) { create(:meeting_component, participatory_space: participatory_process) }
  let!(:unreported_resource) { create(:meeting, component:, author:, title: { en: "This is a very good ideea!" }, description: { en: "This is a very good ideea! " }) }
  let!(:reported_resource) { create(:meeting, component:, author:, title: { en: "Winner, Blody Winner" }, description: { en: "You are the lucky winner! Claim your holiday prize." }) }
  let(:moderation) do
    create(:moderation, :hidden, reportable: reported_resource, report_count: 3,
                                 reported_content: reported_resource.reported_searchable_content_text)
  end
  let!(:report) { create(:report, moderation:, user: system_user, reason: "spam") }

  before do
    Decidim::Ai.backend = :memory
    Decidim::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
    Decidim::Ai.load_vendor_data = false
    Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Meeting)
    Decidim::Ai::SpamContent::Repository.train!
  end

  context "when spam content is added" do
    let(:description) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 1 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Meetings::Meeting }
    end
  end

  context "when regular content content is added" do
    let(:description) { "Very nice ideea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 0 }
      let(:compared_field) { :description }
      let(:compared_against) { description }
      let(:resource) { Decidim::Meetings::Meeting }
    end
  end
end

shared_examples "proposal spam analysis" do
  let(:component) { create(:proposal_component) }
  let(:organization) { component.organization }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }
  let(:author) { create(:user, organization:) }
  let(:user_group) { create(:user_group, :verified, organization:, users: [author]) }
  let!(:unreported_resource) { create(:proposal, component:, users: [author], title: { en: "This is a very good ideea!" }, body: { en: "This is a very good ideea! " }) }
  let!(:reported_resource) { create(:proposal, component:, users: [author], title: { en: "Winner, Blody Winner" }, body: { en: "You are the lucky winner! Claim your holiday prize." }) }
  let(:moderation) do
    create(:moderation, :hidden, reportable: reported_resource, report_count: 3,
                                 reported_content: reported_resource.reported_searchable_content_text)
  end
  let!(:report) { create(:report, moderation:, user: system_user, reason: "spam") }

  before do
    Decidim::Ai.backend = :memory
    Decidim::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
    Decidim::Ai.load_vendor_data = false
    Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Proposal)
    Decidim::Ai::SpamContent::Repository.train!
  end

  context "when spam content is added" do
    let(:body) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 1 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::Proposal }
    end
  end

  context "when regular content content is added" do
    let(:body) { "Very nice ideea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 0 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::Proposal }
    end
  end
end

shared_examples "Collaborative draft spam analysis" do
  let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled) }
  let(:organization) { component.organization }
  let!(:system_user) { create(:user, :confirmed, email: Decidim::Ai.reporting_user_email, organization:) }
  let(:author) { create(:user, organization:) }
  let(:user_group) { create(:user_group, :verified, organization:, users: [author]) }

  let!(:unreported_resource) { create(:collaborative_draft, component:, users: [author], title: "This is a very good ideea!", body: "This is a very good ideea! ") }
  let!(:reported_resource) { create(:collaborative_draft, component:, users: [author], title: "Winner, Blody Winner", body: "You are the lucky winner! Claim your holiday prize.") }
  let(:moderation) do
    create(:moderation, :hidden, reportable: reported_resource, report_count: 3,
                                 reported_content: reported_resource.reported_searchable_content_text)
  end
  let!(:report) { create(:report, moderation:, user: system_user, reason: "spam") }

  let(:form) do
    Decidim::Proposals::CollaborativeDraftForm.from_params(
      title:,
      body:,
      address: nil,
      has_address: false,
      latitude: 40.1234,
      longitude: 2.1234,
      add_documents: nil,
      user_group_id: user_group.try(:id),
      suggested_hashtags: []
    ).with_context(
      current_user: author,
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_component: component
    )
  end

  before do
    Decidim::Ai.backend = :memory
    Decidim::Ai.spam_treshold = 0.2 # it has to be lower or equal to 0.25
    Decidim::Ai.load_vendor_data = false
    Decidim::Ai.trained_models = %w(Decidim::Tools::Ai::Resource::CollaborativeDraft)
    Decidim::Tools::Ai::SpamContent::Repository.train!
  end

  context "when spam content is added" do
    let(:body) { "Claim your prize today so you can win." }
    let(:title) { "You are the Lucky winner" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 1 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::CollaborativeDraft }
    end
  end

  context "when regular content content is added" do
    let(:body) { "Very nice ideea that is not going to be blocked by engine" }
    let(:title) { "This is the collaborative draft title" }

    include_examples "content submitted to spam analysis" do
      let(:queue_size) { 1 }
      let(:spam_count) { 0 }
      let(:compared_field) { :body }
      let(:compared_against) { body }
      let(:resource) { Decidim::Proposals::CollaborativeDraft }
    end
  end
end

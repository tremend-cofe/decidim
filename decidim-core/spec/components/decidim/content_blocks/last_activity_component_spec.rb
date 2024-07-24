# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ContentBlocks::LastActivityComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :last_activity, scope_name: :homepage, settings:) }
  let(:settings) { {} }
  let(:component) { create(:component, :published, organization:) }

  controller Decidim::PagesController

  before do
    allow(Decidim::ActionLog).to receive(:public_resource_types).and_return(
      %w(Decidim::Dev::DummyResource)
    )
    allow(Decidim::ActionLog).to receive(:publicable_public_resource_types).and_return(
      %w(Decidim::Dev::DummyResource)
    )
  end

  describe "valid_activities" do
    let!(:action_log) { create(:action_log, action: "publish", visibility: "all", resource:, organization:) }
    let(:resource) { create(:dummy_resource, component:, published_at: Time.current) }

    it "includes current action log" do
      render_inline(subject)
      expect(page).to have_content(translated(action_log.resource.title))
      expect(subject.activities).to include(action_log)
    end

    context "when the participatory space is missing" do

      it "excludes current action log" do
        action_log.participatory_space.delete
        render_inline(subject)
        expect(page).to have_no_content(translated(action_log.resource.title))
        expect(subject.activities).not_to include(action_log)
      end
    end

    context "when the resource is missing" do
      it "excludes current action log" do
        resource.delete
        render_inline(subject)
        expect(page).to have_no_content(translated(action_log.resource.title))
        expect(subject.valid_activities).not_to include(action_log)
      end
    end

    context "when the resource has been hidden" do
      it "excludes current action log" do
        create(:moderation, :hidden, reportable: action_log.resource)
        render_inline(subject)
        expect(page).to have_no_content(translated(action_log.resource.title))
        expect(subject.activities).not_to include(action_log)
      end
    end

    context "with a lot of activities" do
      before do
        10.times do
          dummy_resource = create(:dummy_resource, component:, published_at: Time.current)
          create(:action_log, action: "publish", visibility: "all", resource: dummy_resource, organization:)
        end
      end

      it "limits the results" do
        render_inline(subject)
        expect(subject.valid_activities.length).to eq(8)
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ContentBlocks::HighlightedContentBannerComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:highlighted_content_banner_enabled) { true }
  let(:organization) do
    create(:organization,
       highlighted_content_banner_enabled: ,
       highlighted_content_banner_title: Decidim::Faker::Localized.sentence(word_count: 2),
       highlighted_content_banner_short_description: Decidim::Faker::Localized.sentence(word_count: 2),
       highlighted_content_banner_action_title: Decidim::Faker::Localized.sentence(word_count: 2),
       highlighted_content_banner_action_subtitle: Decidim::Faker::Localized.sentence(word_count: 2),
       highlighted_content_banner_action_url: Faker::Internet.url,
       highlighted_content_banner_image: Decidim::Dev.test_file("city.jpeg", "image/jpeg"))
  end

  let(:content_block) { create(:content_block, organization:, manifest_name: :highlighted_content_banner, scope_name: :homepage, settings:) }
  let(:settings) { {} }

  controller Decidim::PagesController

  context "when the content banner is disabled" do
    let(:highlighted_content_banner_enabled) { false }

    it "hides the banner" do
      render_inline(subject)
      expect(page).not_to have_css("[id^=highlighted_content_banner]", visible: :all)
    end
  end

  context "when the content block has no settings" do
    it "shows the default welcome text" do
      render_inline(subject)
      expect(page).to have_css("[id^=highlighted_content_banner]", visible: :all)
      expect(page).to have_content(translated(organization.highlighted_content_banner_title))
      expect(page).to have_content(translated(organization.highlighted_content_banner_short_description))
      expect(page).to have_content(translated(organization.highlighted_content_banner_action_title))
      expect(page).to have_content(translated(organization.highlighted_content_banner_action_subtitle))
    end
  end
end

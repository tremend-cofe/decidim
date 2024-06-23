# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ContentBlocks::SubHeroComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization, description: { en: description }, users_registration_mode:) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :sub_hero, scope_name: :homepage, settings: {}) }
  let(:description) { "Let's build a more open, transparent and collaborative society." }
  let(:users_registration_mode) { "enabled" }

  controller Decidim::PagesController

  context "when the content block has no settings" do
    it "shows the default welcome text" do
      render_inline(subject)
      expect(page).to have_text("Let's build a more open, transparent and collaborative society.")
      expect(page).to have_text("Register")
    end
  end

  context "when there is no organization set" do
    let(:description) { "" }

    it "hides the register button" do
      render_inline(subject)
      expect(page).to have_no_text("Let's build a more open, transparent and collaborative society.")
    end
  end

  context "when the user is not logged in" do
    let!(:user) { create(:user, organization:) }

    it "hides the register button" do
      render_inline(subject)
      expect(page).to have_no_text("Register")
    end
  end

  context "when organization settings prevent registration" do
    let(:users_registration_mode) { "disabled" }

    it "hides the register button" do
      render_inline(subject)
      expect(page).to have_no_text("Register")
    end
  end
end

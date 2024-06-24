# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ContentBlocks::HtmlComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :html, scope_name: :homepage, settings:) }
  let(:settings) { {} }

  controller Decidim::PagesController


  it "displays the content" do
    render_inline(subject)
    expect(page).to have_css("[id^=html-block-#{content_block.id}]", visible: :all)
  end

  context "when has settings" do
    let(:settings) { { html_content_en: %(<p id="html-test-content">This is a Decidim world</p>) } }

    it "displays the content" do
      render_inline(subject)

      expect(page).to have_content("This is a Decidim world")
      expect(page).to have_css("[id=html-test-content]", visible: :all)
      expect(page).not_to have_content(%(<p id="html-test-content">This is a Decidim world</p>))
    end
  end

end

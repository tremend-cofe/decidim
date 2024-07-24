# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ContentBlocks::GlobalMenuComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :global_menu, scope_name: :homepage, settings: {}) }

  controller Decidim::PagesController

  it "displays the menu" do
    Decidim::MenuRegistry.register :home_content_block_menu do |menu|
      menu.add_item :processes, "Processes", "/foo"
      menu.add_item :assemblies, "Assemblies", "/bar"
      menu.add_item :initiatives, "Initiatives", "/bar"
      menu.add_item :conferences, "Conferences", "/bar"
    end

    render_inline(subject)

    expect(page).to have_content("Processes")
    expect(page).to have_content("Assemblies")
    expect(page).to have_content("Initiatives")
    expect(page).to have_content("Conferences")
  end
end

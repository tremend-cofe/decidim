# frozen_string_literal: true

require "spec_helper"

RSpec.describe Decidim::ContentBlocks::HowToParticipateComponent, type: :component do
  subject { described_class.new(content_block) }

  let(:organization) { create(:organization) }
  let(:content_block) { create(:content_block, organization:, manifest_name: :how_to_participate, scope_name: :homepage) }

  controller Decidim::PagesController

  it "displays the content" do
    render_inline(subject)
    expect(page).to have_css("[id^=how_to_participate]", visible: :all)

    expect(page).to have_content("How do I take part in a process?")
    expect(page).to have_content("Find out where and when you can participate in public meetings.")
    expect(page).to have_content("Debate and discuss, share your views and enrich the relevant topics.")
    expect(page).to have_content("Make proposals, support existing ones and promote the changes you want to see.")
    expect(page).to have_content("More info about #{translated(organization.name)}")
  end
end

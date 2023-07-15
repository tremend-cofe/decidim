# frozen_string_literal: true

require "spec_helper"

describe "User updates collaborative draft", type: :system do
  let(:command) do
    Decidim::Proposals::UpdateCollaborativeDraft.new(form, author, collaborative_draft)
  end

  include_examples "Collaborative draft spam analysis" do
    let!(:collaborative_draft) { create(:collaborative_draft, component:, users: [author], title: "Some draft that is not blocked", body: "The body for the proposal.") }
  end
end

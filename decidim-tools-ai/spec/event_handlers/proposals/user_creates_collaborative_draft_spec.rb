# frozen_string_literal: true

require "spec_helper"

describe "User creates collaborative draft", type: :system do
  let(:command) { Decidim::Proposals::CreateCollaborativeDraft.new(form, author) }

  include_examples "Collaborative draft spam analysis"
end

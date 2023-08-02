# frozen_string_literal: true

require "spec_helper"

describe "User updates meeting", type: :system do
  let(:uploaded_files) { [] }
  let(:current_files) { [] }
  let(:signature_type) { "online" }
  let(:attachment) { nil }
  let(:scoped_type) { create(:initiatives_type_scope) }
  let(:type_id) { scoped_type.type.id}

  let(:form) do
    Decidim::Initiatives::InitiativeForm.from_params(
      title:,
      description:,
      signature_type:,
      type_id:,
      attachment:,
      add_documents: uploaded_files,
      documents: current_files
    ).with_context(
      current_organization: organization,
      current_user: author
    )
  end

  let(:command) { Decidim::Initiatives::UpdateInitiative.new(initiative, form, author) }

  include_examples "initiatives spam analysis" do
    let!(:author) { create(:user, :confirmed, organization:) }

    let!(:initiative) do
      create(:initiative, author:,
                      title: { en: "Some proposal that is not blocked" },
                      description: { en: "The body for the meeting." })
    end
  end
end

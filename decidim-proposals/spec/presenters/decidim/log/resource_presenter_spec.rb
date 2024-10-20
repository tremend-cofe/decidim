# frozen_string_literal: true

require "spec_helper"

describe Decidim::Log::ResourcePresenter, type: :helper do
  let(:presenter) { described_class.new(resource, helper, extra) }
  let(:resource) { create(:proposal, title: Faker::Book.unique.title) }
  let(:extra) do
    {
      "title" => Faker::Book.unique.title
    }
  end
  let(:resource_path) { Decidim::ResourceLocatorPresenter.new(resource).path }

  context "when the resource exists" do
    it "links to its public page with the name of the proposal" do
      html = presenter.present
      expect(html).to have_link(translated(resource.title), href: resource_path)
    end
  end

  context "when the resource does not exist" do
    let(:resource) { nil }
    let(:extra) do
      {
        "title" => "My title"
      }
    end

    it "does not link to its public page but renders its name" do
      expect(presenter.present).to have_no_link("My title")
    end
  end
end

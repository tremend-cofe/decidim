# frozen_string_literal: true

require "spec_helper"

describe "Admin manages forbidden words", type: :system do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_ai_tools.forbidden_keywords_path
  end

  describe "listing forbidden words" do
    let(:forbidden_word) { create(:forbidden_word, organization:) }
    let!(:word) { forbidden_word.word }

    before do
      visit decidim_admin_ai_tools.forbidden_keywords_path
    end

    it "shows a table with the templates info" do
      within ".forbidden_keywords" do
        expect(page).to have_content(word)
      end
    end
  end

  describe "creating a new forbidden word" do
    before do
      within ".layout-content" do
        click_link("New forbidden keywords")
      end
    end

    it "creates a new forbidden keyword" do
      within ".new_forbidden_keyword" do
        fill_in :forbidden_keyword_word, with: "prize"
        page.find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("Successfully")
    end
  end

  describe "trying to create a forbidden keyword with invalid data" do
    let(:forbidden_word) { create(:forbidden_word, organization:) }
    let!(:word) { forbidden_word.word }

    before do
      within ".layout-content" do
        click_link("New forbidden keywords")
      end
    end

    it "creates a new forbidden keyword" do
      within ".new_forbidden_keyword" do
        fill_in :forbidden_keyword_word, with: word
        page.find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a forbidden keyword" do
    let!(:forbidden_word) { create(:forbidden_word, organization:) }

    before do
      visit decidim_admin_ai_tools.forbidden_keywords_path
      click_link("Edit")
    end

    it "changes the forbidden keyword" do
      within ".edit_forbidden_keyword" do
        fill_in :forbidden_keyword_word, with: :foobar
        page.find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("Successfully")
    end
  end

  describe "destroying a forbidden keyword" do
    let(:forbidden_word) { create(:forbidden_word, organization:) }
    let!(:word) { forbidden_word.word }

    before do
      visit decidim_admin_ai_tools.forbidden_keywords_path
    end

    it "destroys the template" do
      expect(page).to have_content(word)
      within find("tr", text: word) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")
      expect(page).not_to have_content(word)
    end
  end
end

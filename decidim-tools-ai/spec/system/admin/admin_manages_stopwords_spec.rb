# frozen_string_literal: true

require "spec_helper"

describe "Admin manages stopwords", type: :system do
  let(:organization) { create(:organization) }
  let(:admin) { create(:user, :admin, :confirmed, organization:) }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin_ai_tools.stopwords_path
  end

  describe "listing Stop Words" do
    let(:stopword) { create(:stopword, organization:) }
    let!(:word) { stopword.word }

    before do
      visit decidim_admin_ai_tools.stopwords_path
    end

    it "shows a table with the templates info" do
      within ".stopwords" do
        expect(page).to have_content(word)
      end
    end
  end

  describe "creating a new stopword" do
    before do
      within ".layout-content" do
        click_link("New ignored word")
      end
    end

    it "creates a new stopword" do
      within ".new_stopword" do
        fill_in :stopword_word, with: "prize"
        page.find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("Successfully")
    end
  end

  describe "trying to create a stopwords with invalid data" do
    let(:stopword) { create(:stopword, organization:) }
    let!(:word) { stopword.word }

    before do
      within ".layout-content" do
        click_link("New ignored word")
      end
    end

    it "creates a new stopwords" do
      within ".new_stopword" do
        fill_in :stopword_word, with: word
        page.find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("problem")
    end
  end

  describe "updating a stopwords" do
    let!(:stopword) { create(:stopword, organization:) }

    before do
      visit decidim_admin_ai_tools.stopwords_path
      click_link("Edit")
    end

    it "changes the stopwords" do
      within ".edit_stopword" do
        fill_in :stopword_word, with: :foobar
        page.find("*[type=submit]").click
      end
      expect(page).to have_admin_callout("Successfully")
    end
  end

  describe "destroying a stopwords" do
    let(:stopword) { create(:stopword, organization:) }
    let!(:word) { stopword.word }

    before do
      visit decidim_admin_ai_tools.stopwords_path
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

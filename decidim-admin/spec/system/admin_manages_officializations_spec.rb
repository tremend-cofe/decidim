# frozen_string_literal: true

require "spec_helper"

describe "Admin manages officializations", type: :system do
  include_context "with filterable context"

  let(:model_name) { Decidim::User.model_name }
  let(:resource_controller) { Decidim::Admin::OfficializationsController }

  let(:organization) { create(:organization) }

  let!(:admin) { create(:user, :admin, :confirmed, organization:) }

  let(:profile_selector) { Decidim.redesign_active ? "div.bg-background" : ".profile--sidebar" }

  before do
    switch_to_host(organization.host)
    login_as admin, scope: :user
    visit decidim_admin.root_path
    click_link "Participants"
  end

  describe "moderation" do
    before do
      within ".secondary-nav" do
        click_link "Participants"
      end
    end

    let!(:first_moderation) { create(:user_moderation, user: first_user, report_count: 1) }
    let!(:second_moderation) { create(:user_moderation, user: second_user, report_count: 1) }
    let!(:third_moderation) { create(:user_moderation, user: third_user, report_count: 1) }
    let!(:first_user_report) { create(:user_report, moderation: first_moderation, user: admin, reason: "spam") }
    let!(:second_user_report) { create(:user_report, moderation: second_moderation, user: admin, reason: "offensive") }
    let!(:third_user_report) { create(:user_report, moderation: third_moderation, user: admin, reason: "does_not_belong") }

    context "when filtering blocked users" do
      let!(:first_user) { create(:user, :confirmed, :blocked, organization:) }
      let!(:fourth_user) { create(:user, :confirmed, organization:) }

      it_behaves_like "a filtered collection", options: "Blocked", filter: "Blocked" do
        let(:in_filter) { first_user.name }
        let(:not_in_filter) { fourth_user.name }
      end

      it_behaves_like "a filtered collection", options: "Blocked", filter: "Not blocked" do
        let(:in_filter) { fourth_user.name }
        let(:not_in_filter) { first_user.name }
      end
    end

    context "when filtering by report reason" do

      let!(:first_user) { create(:user, :confirmed, organization:) }
      let!(:second_user) { create(:user, :confirmed, organization:) }
      let!(:third_user) { create(:user, :confirmed, organization:) }
      let!(:fourth_user) { create(:user, :confirmed, organization:) }

      context "when sorting" do
        context "with report count" do
          it "sorts reported users by report count" do
            click_link "Reports"

            all("tbody").last do
              expect(all("tr").first.text).to include(fourth_user.name)
              expect(all("tr").last.text).to include(third_user.name)
            end
          end
        end

        context "with report reason" do
          it "sorts reported users by report count" do
            click_link "Report reasons"

            all("tbody").last do
              expect(all("tr").first.text).to include(fourth_user.name)
              expect(all("tr").last.text).to include(first_user.name)
            end
          end
        end
      end

      it_behaves_like "a filtered collection", options: "Is reported", filter: "Empty" do
        let(:in_filter) { fourth_user.name }
        let(:not_in_filter) { second_user.name }

        it "cannot be found by nickname if has reporting" do
          search_by_text(first_user.nickname)

          expect(page).not_to have_content(second_user.name)
          expect(page).not_to have_content(first_user.name)
          expect(page).not_to have_content(third_user.name)
          expect(page).not_to have_content(fourth_user.name)
        end
        it "can be searched by nickname" do
          search_by_text(fourth_user.nickname)

          expect(page).not_to have_content(second_user.name)
          expect(page).not_to have_content(first_user.name)
          expect(page).not_to have_content(third_user.name)
          expect(page).to have_content(fourth_user.name)
        end

        it "cannot be found by email if has reporting" do
          search_by_text(first_user.email)

          expect(page).not_to have_content(second_user.name)
          expect(page).not_to have_content(first_user.name)
          expect(page).not_to have_content(third_user.name)
          expect(page).not_to have_content(fourth_user.name)
        end

        it "can be searched by email" do
          search_by_text(fourth_user.email)

          expect(page).not_to have_content(second_user.name)
          expect(page).not_to have_content(first_user.name)
          expect(page).not_to have_content(third_user.name)
          expect(page).to have_content(fourth_user.name)
        end
        it "cannot be found by name if has reporting" do
          search_by_text(first_user.name)

          expect(page).not_to have_content(second_user.name)
          expect(page).not_to have_content(first_user.name)
          expect(page).not_to have_content(third_user.name)
          expect(page).not_to have_content(fourth_user.name)
        end

        it "can be searched by name" do
          search_by_text(fourth_user.name)

          expect(page).not_to have_content(second_user.name)
          expect(page).not_to have_content(first_user.name)
          expect(page).not_to have_content(third_user.name)
          expect(page).to have_content(fourth_user.name)
        end
      end

      it_behaves_like "a filtered collection", options: "Is reported", filter: "Present" do
        let(:in_filter) { first_user.name }
        let(:not_in_filter) { fourth_user.name }
      end

      it_behaves_like "a filtered collection", options: "Is reported", filter: "Spam" do
        let(:in_filter) { first_user.name }
        let(:not_in_filter) { second_user.name }
      end

      it_behaves_like "a filtered collection", options: "Is reported", filter: "Offensive" do
        let(:in_filter) { second_user.name }
        let(:not_in_filter) { first_user.name }
      end

      it_behaves_like "a filtered collection", options: "Is reported", filter: "Does not belong" do
        let(:in_filter) { third_user.name }
        let(:not_in_filter) { second_user.name }
      end
    end

  end

  describe "listing officializations" do
    let!(:officialized) { create(:user, :officialized, organization:) }
    let!(:not_officialized) { create(:user, organization:) }
    let!(:deleted) do
      user = create(:user, organization:)
      result = Decidim::DestroyAccount.call(user, OpenStruct.new(valid?: true, delete_reason: "Testing"))
      result["ok"]
    end
    let!(:external_not_officialized) { create(:user) }

    before do
      within ".secondary-nav" do
        click_link "Participants"
      end
    end

    it_behaves_like "a filtered collection", options: "State", filter: "Officialized" do
      let(:in_filter) { officialized.name }
      let(:not_in_filter) { not_officialized.name }
    end

    it_behaves_like "a filtered collection", options: "State", filter: "Not officialized" do
      let(:in_filter) { not_officialized.name }
      let(:not_in_filter) { officialized.name }
    end

    it_behaves_like "paginating a collection"
  end

  describe "officializating users" do
    context "when not yet officialized" do
      let!(:user) { create(:user, organization:) }

      before do
        within ".secondary-nav" do
          click_link "Participants"
        end

        within "tr[data-user-id=\"#{user.id}\"]" do
          click_link "Officialize"
        end
      end

      it "officializes it with the standard badge" do
        click_button "Officialize"

        expect(page).to have_content("successfully officialized")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_content("Officialized")
        end
      end

      it "officializes it with a custom badge" do
        fill_in_i18n(
          :officialization_officialized_as,
          "#officialization-officialized_as-tabs",
          en: "Major of Barcelona",
          es: "Alcaldesa de Barcelona"
        )

        click_button "Officialize"

        expect(page).to have_content("successfully officialized")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_content("Officialized").and have_content("Major of Barcelona")
        end
      end
    end

    context "when officialized already" do
      let!(:user) do
        create(
          :user,
          :officialized,
          officialized_as: { "en" => "Mayor of Barcelona" },
          organization:
        )
      end

      before do
        within ".secondary-nav" do
          click_link "Participants"
        end

        within "tr[data-user-id=\"#{user.id}\"]" do
          click_link "Reofficialize"
        end
      end

      it "allows changing the officialization label" do
        expect(page).to have_field("officialization_officialized_as_en", with: "Mayor of Barcelona")

        fill_in_i18n(
          :officialization_officialized_as,
          "#officialization-officialized_as-tabs",
          en: "Major of Barcelona"
        )
        click_button "Officialize"

        expect(page).to have_content("successfully officialized")

        within "tr[data-user-id=\"#{user.id}\"]" do
          expect(page).to have_content("Officialized").and have_content("Major of Barcelona")
        end
      end
    end
  end

  describe "unofficializating users" do
    let!(:user) { create(:user, :officialized, organization:) }

    before do
      within ".secondary-nav" do
        click_link "Participants"
      end

      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link "Unofficialize"
      end
    end

    it "unofficializes user and goes back to list" do
      expect(page).to have_content("successfully unofficialized")

      within "tr[data-user-id=\"#{user.id}\"]" do
        expect(page).to have_content("Not officialized")
      end
    end
  end

  describe "contacting the user" do
    let!(:user) { create(:user, organization:) }

    before do
      within ".secondary-nav" do
        click_link "Participants"
      end
    end

    it "redirect to conversation path" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link "Contact"
      end
      expect(page).to have_current_path decidim.new_conversation_path(recipient_id: user.id)
    end
  end

  describe "clicking on user name" do
    let!(:user) { create(:user, organization:) }

    before do
      within ".secondary-nav" do
        click_link "Participants"
      end
    end

    it "redirect to user profile page" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link user.name
      end

      within profile_selector, match: :first do
        expect(page).to have_content(user.name)
      end
    end
  end

  describe "clicking on user nickname" do
    let!(:user) { create(:user, organization:) }

    before do
      within ".secondary-nav" do
        click_link "Participants"
      end
    end

    it "redirect to user profile page" do
      within "tr[data-user-id=\"#{user.id}\"]" do
        click_link user.nickname
      end

      within profile_selector, match: :first do
        expect(page).to have_content(user.name)
      end
    end
  end

  describe "retrieving the user email address" do
    let!(:users) { create_list(:user, 3, organization:) }

    before do
      within ".secondary-nav" do
        click_link "Participants"
      end
    end

    it "shows the users emails to admin users and logs the action" do
      users.each do |user|
        within "tr[data-user-id=\"#{user.id}\"]" do
          click_link "Show email"
        end

        within "#show-email-modal" do
          expect(page).to have_content("Show participant's email address")
          expect(page).not_to have_content(user.email)

          click_button "Show"

          expect(page).to have_content(user.email)

          find("button[data-close]").click
        end
      end

      visit decidim_admin.root_path

      users.each do |user|
        expect(page).to have_content("#{admin.name} retrieved the email of the participant #{user.name}")
      end
    end
  end
end

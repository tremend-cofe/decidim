# frozen_string_literal: true

require "spec_helper"

describe Decidim::Comments::CommentCreatedEvent do
  include_context "when it's a comment event"
  let(:event_name) { "decidim.events.comments.comment_created" }

  it_behaves_like "a comment event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("There is a new comment from #{comment_author.name} in #{resource_title}")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro).to eq("#{resource_title} has been commented. You can read the comment in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{resource_title}\" or its author. You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("There is a new comment from <a href=\"/profiles/#{comment_author.nickname}\">#{comment_author.name} @#{comment_author.nickname}</a>")

      expect(subject.notification_title)
        .to include(" in <a href=\"#{resource_path}#comment_#{comment.id}\">#{resource_title}</a>")
    end
  end

  context "when is machine machine translated" do
    context "when priority is original" do
      let(:organization) { create(:organization, name: "O'Connor", enable_machine_translations: true, machine_translation_display_priority: "original") }
    end

    context "when priority is translation" do
      let(:organization) { create(:organization, name: "O'Connor", enable_machine_translations: true, machine_translation_display_priority: "translation") }
    end
  end

end

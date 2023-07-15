# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tools
    module Ai
      describe TrainHiddenResourceDataJob do
        subject { described_class }
        let(:organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization:) }
        let(:component) { create(:component, participatory_space: participatory_process) }
        let(:dummy_resource) { create(:dummy_resource, component:) }
        let(:commentable) { dummy_resource }
        let(:author) { create(:user, organization:) }

        let!(:comment) { create(:comment, author:, commentable:, body: { en: "This is a very good ideea! " }) }
        let(:engine_backend) { Decidim::Ai::SpamContent::Repository.new }

        before do
          Decidim::Ai.backend = :memory
          Decidim::Ai.load_vendor_data = false
          Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Comment)

          engine_backend.train!
        end

        it "adds data to spam" do
          expect(engine_backend.backend.category_word_count(:Normal)).to eq(4)
          expect(engine_backend.backend.category_word_count(:Spam)).to eq(0)

          moderation = Decidim::Moderation.find_or_create_by!(reportable: comment, participatory_space: participatory_process)
          moderation.update!(
            reported_content: comment.reported_searchable_content_text,
            report_count: Decidim.max_reports_before_hiding,
            hidden_at: Time.current
          )
          Decidim::Report.create!(
            moderation:,
            user: comment.author,
            reason: "spam",
            details: "testing purposes",
            locale: I18n.locale
          )

          subject.perform_now(comment, engine_backend)
          expect(engine_backend.backend.category_word_count(:Normal)).to eq(0)
          expect(engine_backend.backend.category_word_count(:Spam)).to eq(4)
        end
      end
    end
  end
end

# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tools
    module Ai
      describe TrainUserDataJob do
        subject { described_class }
        let(:organization) { create(:organization) }
        let!(:user) { create(:user, :confirmed, organization:, about: "This is a short info about me") }

        let(:engine_backend) { Decidim::Ai::SpamContent::Repository.new }

        before do
          Decidim::Ai.backend = :memory
          Decidim::Ai.load_vendor_data = false
          Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::UserBaseEntity)

          engine_backend.train!
        end

        it "adds data to spam" do
          expect(engine_backend.backend.category_word_count(:Normal)).to eq(3)
          expect(engine_backend.backend.category_word_count(:Spam)).to eq(0)
          user.blocked = true
          user.save!
          subject.perform_now(user, engine_backend)
          expect(engine_backend.backend.category_word_count(:Normal)).to eq(0)
          expect(engine_backend.backend.category_word_count(:Spam)).to eq(3)
        end
      end
    end
  end
end

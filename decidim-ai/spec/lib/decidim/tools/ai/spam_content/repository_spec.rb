# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Tools
    module Ai
      module SpamContent
        describe Repository do
          subject { described_class.new }
          let(:backend) { subject.backend }

          describe "classify" do
            before do
              Decidim::Ai.backend = :memory
              Decidim::Ai.load_vendor_data = false
              Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Comment)
            end

            let(:organization) { create(:organization) }
            let(:participatory_process) { create(:participatory_process, organization:) }
            let(:component) { create(:dummy_component, participatory_space: participatory_process) }
            let(:commentable) { create(:dummy_resource, component:) }
            let!(:comment1) { create(:comment, commentable:, body: "here are some good words. I hope you love them") }
            let!(:comment2) { create(:comment, commentable:, body: "Hi! My name is Nick Hunter. I am working as an educational content writer at The Academic Papers in the United Kingdom. I have seven years of experience working as an academic writer. I have completed several tasks and submitted them within the time limit. We provide dissertation editing services. If you face any difficulty writing your academic papers, feel free to ask me anytime, and I will guide you.") }
            let!(:moderation) { create(:moderation, :hidden, reportable: comment2, report_count: 3, reported_content: comment2.reported_searchable_content_text) }
            let!(:report) { create(:report, moderation:, user: comment1.author, reason: "spam") }

            it "successfully classifies" do
              subject.train!
              expect(subject.classify("We provide dissertation editing services.")).to eq("Spam")
              expect(subject.classify("A really sweet language")).not_to eq("Spam")
            end
          end

          describe "backend" do
            after do
              Decidim::Ai.backend = :memory
            end

            context "when memory backend provided" do
              it "expected to raise error" do
                Decidim::Ai.backend = :memory
                expect(subject.backend).to be_an_instance_of(ClassifierReborn::BayesMemoryBackend)
              end
            end

            context "when redis backend provided" do
              it "expected to raise error" do
                Decidim::Ai.backend = :redis
                Decidim::Ai.redis_configuration = {
                  host: ENV.fetch("DECIDIM_SPAM_REDIS_HOST", nil)
                }
                expect(subject.backend).to be_an_instance_of(ClassifierReborn::BayesRedisBackend)
              end
            end

            context "when invalid backend provided" do
              it "expected to raise error" do
                Decidim::Ai.backend = :invalid
                expect { subject.backend }.to raise_error(InvalidBackendError)
              end
            end
          end

          describe "train" do
            let(:organization) { create(:organization) }
            let(:participatory_process) { create(:participatory_process, organization:) }

            before do
              Decidim::Ai.backend = :memory
              Decidim::Ai.load_vendor_data = false
            end

            context "when having comments" do
              let(:component) { create(:dummy_component, participatory_space: participatory_process) }
              let(:commentable) { create(:dummy_resource, component:) }
              let!(:resources) { create_list(:comment, 2, commentable:) }

              before do
                Decidim::Ai.backend = :memory
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Comment)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(2)
              end
            end

            context "when having meetings" do
              let(:component) { create(:meeting_component, participatory_space: participatory_process) }
              let!(:resources) { create_list(:meeting, 2, component:) }

              before do
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Meeting)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(8) # there are 2 meetings with 4 fields each
              end
            end

            context "when having proposals" do
              let(:component) { create(:proposal_component, participatory_space: participatory_process) }
              let!(:resources) { create_list(:proposal, 2, component:) }

              before do
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Proposal)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(4)
              end
            end

            context "when having collaborative_drafts" do
              let(:component) { create(:proposal_component, :with_collaborative_drafts_enabled, participatory_space: participatory_process) }
              let!(:resources) { create_list(:collaborative_draft, 2, component:) }

              before do
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::CollaborativeDraft)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(4)
              end
            end

            context "when having debates" do
              let(:component) { create(:debates_component, participatory_space: participatory_process) }
              let!(:resources) { create_list(:debate, 2, component:) }

              before do
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::Debate)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(4) # there are 2 debates with 2 fields each
              end
            end

            context "when having users" do
              let!(:resources) { create_list(:user, 2, organization:) }

              before do
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::UserBaseEntity)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(2)
              end
            end

            context "when having user_groups" do
              let!(:resources) { create_list(:user_group, 2, organization:) }

              before do
                Decidim::Ai.load_vendor_data = false
                Decidim::Ai.trained_models = %w(Decidim::Ai::Resource::UserBaseEntity)
                subject.train!
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(2)
              end
            end
          end

          describe "load_sample_data!" do
            context "when is enabled" do
              before do
                Decidim::Ai.load_vendor_data = true
                subject.train!
              end

              after do
                Decidim::Ai.load_vendor_data = false
              end

              it "add the data to classifier" do
                expect(backend.total_trainings).to eq(5901)
              end
            end
          end

          describe "load_from_file!" do
            let!(:path) { Gem.loaded_specs["decidim-tools-ai"].full_gem_path }
            let!(:file) { "spec/support/test.csv" }

            before do
              Decidim::Ai.load_vendor_data = false
              subject.train!
            end

            it "add the data to classifier" do
              subject.load_from_file!("#{path}/#{file}")
              expect(backend.total_trainings).to eq(4)
            end
          end
        end
      end
    end
  end
end

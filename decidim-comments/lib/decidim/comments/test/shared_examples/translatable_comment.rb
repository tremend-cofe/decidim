# frozen_string_literal: true

require "spec_helper"

shared_examples_for "a translated comment event" do
  describe "translated notifications" do
    let(:body) { { "en": "This is Sparta!", "machine_translations": { "ca": "C'est Sparta!" } } }
    let(:participatory_process) { create :participatory_process, organization: organization }
    let(:component) { create(:component, participatory_space: participatory_process) }
    let(:commentable) { create(:dummy_resource, component: component) }
    let(:comment) { create :comment, body: body, commentable: commentable }

    context "when it is not machine machine translated" do
      let(:organization) { create(:organization, enable_machine_translations: false, machine_translation_display_priority: "original") }

      it "does not perform translation" do
        expect(subject.perform_translation?).to eq(false)
      end

      it "does not have a missing translation" do
        expect(subject.translation_missing?).to eq(false)
      end

      it "does have content available in multiple languages" do
        expect(subject.content_in_same_language?).to eq(false)
      end

      it "does return the original language" do
        expect(subject.safe_resource_text).to eq(subject.resource_text)
      end

      it "does not offer an alternate translation" do
        expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
      end
    end

    context "when is machine machine translated" do
      let(:user) { create :user, organization: organization, locale: "ca" }

      around do |example|
        I18n.with_locale(user.locale) { example.run }
      end

      context "when priority is original" do
        let(:organization) { create(:organization, enable_machine_translations: true, machine_translation_display_priority: "original") }

        it "does perform translation" do
          expect(subject.perform_translation?).to eq(translatable)
        end

        it "does not have a missing translation" do
          expect(subject.translation_missing?).to eq(false)
        end

        it "does have content available in multiple languages" do
          expect(subject.content_in_same_language?).to eq(false)
        end

        it "does return the original language" do
          expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>")
        end

        context "when translation is not available" do
          let(:body) { { "en": "This is Sparta!" } }

          it "does perform translation" do
            expect(subject.perform_translation?).to eq(translatable)
          end

          it "does have a missing translation" do
            expect(subject.translation_missing?).to eq(translatable)
          end

          it "does have content available in multiple languages" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does return the original language" do
            expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
          end
        end
      end

      context "when priority is translation" do
        let(:organization) { create(:organization, enable_machine_translations: true, machine_translation_display_priority: "translation") }

        it "does perform translation" do
          expect(subject.perform_translation?).to eq(translatable)
        end

        it "does not have a missing translation" do
          expect(subject.translation_missing?).to eq(false)
        end

        it "does have content available in multiple languages" do
          expect(subject.content_in_same_language?).to eq(false)
        end

        it "does return the original language" do
          expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
        end

        it "does not offer an alternate translation" do
          expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["machine_translations"]["ca"]}</p></div>")
        end

        context "when translation is not available" do
          let(:body) { { "en": "This is Sparta!" } }

          it "does perform translation" do
            expect(subject.perform_translation?).to eq(translatable)
          end

          it "does have a missing translation" do
            expect(subject.translation_missing?).to eq(translatable)
          end

          it "does have content available in multiple languages" do
            expect(subject.content_in_same_language?).to eq(false)
          end

          it "does return the original language" do
            expect(subject.safe_resource_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
          end

          it "does not offer an alternate translation" do
            expect(subject.safe_resource_translated_text).to eq("<div><p>#{comment.body["en"]}</p></div>")
          end
        end
      end
    end
  end
end

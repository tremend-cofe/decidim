# frozen_string_literal: true

require "spec_helper"

module Decidim
  describe ContentBlock do
    subject { content_block }

    let(:content_block) { create(:content_block, manifest_name: :hero, scope_name: :homepage) }

    describe ".manifest" do
      it "finds the correct manifest" do
        expect(subject.manifest.name.to_s).to eq content_block.manifest_name
      end
    end

    describe ".images_container" do
      after do
        content_block.images_container.background_image.purge if content_block.images_container.background_image.attached?
      end

      it "responds to the image names" do
        expect(subject.images_container).to respond_to(:background_image)
      end

      context "when the image has not been uploaded" do
        it "returns nil" do
          expect(subject.images_container.attached_uploader(:background_image).url).to be_nil
        end
      end

      context "when the related attachment exists" do
        let(:original_image) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            "image/jpeg"
          )
        end

        before do
          subject.images_container.background_image.purge
          subject.images_container.background_image = original_image
          subject.save
          subject.reload
        end

        it "returns the image" do
          expect(subject.images_container.background_image.attached?).to be true
          expect(subject.images_container.attached_uploader(:background_image).url).not_to be_nil
        end
      end

      context "when the image is larger in size than the organization allows" do
        let(:original_image) do
          Rack::Test::UploadedFile.new(
            Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
            "image/jpeg"
          )
        end

        before do
          content_block.organization.settings.tap do |settings|
            settings.upload.maximum_file_size.default = 1.kilobyte.to_f / 1.megabyte
          end
        end

        it "returns fails to save the image with validation errors" do
          expect(subject.images_container.background_image.attached?).to be false
          subject.images_container.background_image = original_image
          subject.save
          expect(subject.valid?).to be(false)
          expect(subject.errors[:images_container]).to eq(["is invalid"])
          expect(subject.images_container.errors.full_messages).to eq(
            ["Background image file size must be less than or equal to 1 KB"]
          )
          subject.reload
          expect(subject.images_container.background_image.attached?).to be false
        end
      end
    end
  end
end

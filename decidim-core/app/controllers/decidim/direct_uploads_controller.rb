# frozen_string_literal: true

module Decidim
  class DirectUploadsController < ActiveStorage::DirectUploadsController
    before_action :check_organization,
                  :ensure_authenticated!,
                  :check_user_belongs_to_organization,
                  :check_user_not_blocked

    include FormFactory

    helper_method :current_organization

    def create
      blob = ActiveStorage::Blob.create_before_direct_upload!(**blob_args)

      Rails.logger.info current_organization.inspect


      @form = form(Decidim::UploadValidationForm).from_params({
                                                                resource_class: params[:resourceClass],
                                                                property: params[:property],
                                                                form_class: params[:formClass],
                                                                blob: blob.signed_id
                                                              }, { current_organization: })


      render json: direct_upload_json(blob)
    end

    private
    #
    # def blob_args
    #   params.require(:blob).permit(:filename, :byte_size, :checksum, :content_type, metadata: {}).to_h.symbolize_keys
    # end

    def decidim_args
      params.permit(:resourceClass, :property, :formClass, blob: [:filename, :byte_size, :checksum, :content_type, metadata: {}] ).to_h.deep_symbolize_keys
    end

    def direct_upload_json(blob)
      blob.as_json(root: false, methods: :signed_id).merge(direct_upload: {
        url: blob.service_url_for_direct_upload,
        headers: blob.service_headers_for_direct_upload
      })
    end

    def ensure_authenticated!
      head :unauthorized if current_user.blank?
    end

    def check_user_not_blocked
      head :unauthorized if current_user.present? && current_user.blocked?
    end

    def check_user_belongs_to_organization
      head :unauthorized unless current_organization == current_user.organization
    end

    def current_organization
      @current_organization ||= request.env["decidim.current_organization"]
    end

    def check_organization
      head :unauthorized if current_organization.blank?
    end
  end
end

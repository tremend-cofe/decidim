# frozen_string_literal: true

module Decidim
  module Ai
    module Admin
      class ForbiddenKeywordsController < ApplicationController
        include Decidim::Paginable

        helper_method :collection, :word

        def update
          enforce_permission_to(:create, :forbidden_keywords, word:)

          @form = form(Decidim::Ai::Admin::ForbiddenKeywordForm).from_params(params)

          UpdateForbiddenKeyword.call(word, @form, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("forbidden_keyword.update.success", scope: "decidim.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("forbidden_keyword.update.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to(:update, :forbidden_keywords, word:)
          @form = form(Decidim::Ai::Admin::ForbiddenKeywordForm).from_model(word)
        end

        def destroy
          enforce_permission_to(:destroy, :forbidden_keywords, word:)

          DestroyForbiddenKeyword.call(word, current_user) do
            on(:ok) do
              flash[:notice] = I18n.t("forbidden_keyword.destroy.success", scope: "decidim.admin")
              redirect_to action: :index
            end
          end
        end

        def create
          enforce_permission_to :create, :forbidden_keywords

          @form = form(Decidim::Ai::Admin::ForbiddenKeywordForm).from_params(params)

          CreateForbiddenKeyword.call(@form) do
            on(:ok) do
              flash[:notice] = I18n.t("forbidden_keyword.create.success", scope: "decidim.admin")
              redirect_to action: :index
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("forbidden_keyword.create.error", scope: "decidim.admin")
              render :new
            end
          end
        end

        def new
          enforce_permission_to :create, :forbidden_keywords
          @form = form(Decidim::Ai::Admin::ForbiddenKeywordForm).instance
        end

        def index
          enforce_permission_to :index, :forbidden_keywords
          respond_to do |format|
            format.html { render :index }
            format.json do
              term = params[:term]

              @templates = search(term)

              render json: @templates.map { |t| { value: t.id, label: translated_attribute(t.name) } }
            end
          end
        end

        private

        def word
          @word ||= Decidim::Ai::ForbiddenKeyword.where(organization: current_organization).find(params[:id])
        end

        def collection
          @collection ||= paginate(Decidim::Ai::ForbiddenKeyword.where(organization: current_organization))
        end
      end
    end
  end
end

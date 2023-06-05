# frozen_string_literal: true

module Decidim
  module Tools
    module Ai
      module Admin
        class StopwordsController < ApplicationController
          include Decidim::Paginable

          helper_method :collection, :word

          def update
            enforce_permission_to(:create, :stopwords, word:)

            @form = form(Decidim::Tools::Ai::Admin::StopwordForm).from_params(params)

            UpdateForbiddenKeyword.call(word, @form, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("stopword.update.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("stopword.update.error", scope: "decidim.admin")
                render :new
              end
            end
          end

          def edit
            enforce_permission_to(:update, :stopwords, word:)
            @form = form(Decidim::Tools::Ai::Admin::StopwordForm).from_model(word)
          end

          def destroy
            enforce_permission_to(:destroy, :stopwords, word:)

            DestroyStopword.call(word, current_user) do
              on(:ok) do
                flash[:notice] = I18n.t("stopword.destroy.success", scope: "decidim.admin")
                redirect_to action: :index
              end
            end
          end

          def create
            enforce_permission_to :create, :stopwords

            @form = form(Decidim::Tools::Ai::Admin::StopwordForm).from_params(params)

            CreateStopword.call(@form) do
              on(:ok) do
                flash[:notice] = I18n.t("stopword.create.success", scope: "decidim.admin")
                redirect_to action: :index
              end

              on(:invalid) do
                flash.now[:alert] = I18n.t("stopword.create.error", scope: "decidim.admin")
                render :new
              end
            end
          end

          def new
            enforce_permission_to :create, :stopwords
            @form = form(Decidim::Tools::Ai::Admin::StopwordForm).instance
          end

          def index
            enforce_permission_to :index, :stopwords
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
            @word ||= Decidim::Tools::Ai::StopWord.where(organization: current_organization).find(params[:id])
          end

          def collection
            @collection ||= paginate(Decidim::Tools::Ai::StopWord.where(organization: current_organization))
          end
        end
      end
    end
  end
end

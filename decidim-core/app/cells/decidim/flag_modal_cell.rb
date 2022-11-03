# frozen_string_literal: true

module Decidim
  class FlagModalCell < Decidim::ViewModel
    include ActionView::Helpers::FormOptionsHelper

    def flag_user
      render
    end

    # def cache_hash
    #   hash = []
    #   hash.push(I18n.locale)
    #   hash.push(current_user.try(:id))
    #   hash.push(model.reported_by?(current_user) ? 1 : 0)
    #   hash.push(model.class.name.gsub("::", ":"))
    #   hash.push(model.id)
    #   hash.join(Decidim.cache_key_separator)
    # end


    private

    def modal_id
      options[:modal_id] || "flagModal"
    end

    def report_form
      context = { can_hide: model.try(:can_be_administred_by?, current_user) }
      @report_form ||= Decidim::ReportForm.new(reason: "spam").with_context(context)
    end
  end
end

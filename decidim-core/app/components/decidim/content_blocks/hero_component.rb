# frozen_string_literal: true

class Decidim::ContentBlocks::HeroComponent < Decidim::ContentBlocks::BaseComponent
  class CtaButtonComponent < Decidim::BaseComponent
    include Decidim::CtaButtonHelper

    # # Needed so that the `CtaButtonHelper` can work.
    def decidim_participatory_processes = Decidim::ParticipatoryProcesses::Engine.routes.url_helpers
  end

  protected

  def background_image = images_container.attached_uploader(:background_image).path(variant: :big)

  def translated_welcome_text = translated_attribute(settings.welcome_text)

  def cta_button = render(CtaButtonComponent.new)
  
  def welcome_text
    if translated_welcome_text.blank?
      t("decidim.pages.home.hero.welcome", organization: organization_name(organization.name))
    else
      decidim_sanitize_admin translated_welcome_text
    end
  end
end

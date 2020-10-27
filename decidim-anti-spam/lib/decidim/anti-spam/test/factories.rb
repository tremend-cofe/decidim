# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :anti_spam_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :anti_spam).i18n_name }
    manifest_name :anti_spam
    participatory_space { create(:participatory_process, :with_steps) }
  end

  # Add engine factories here
end

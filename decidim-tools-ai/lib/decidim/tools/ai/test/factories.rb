# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/meetings/test/factories"
require "decidim/proposals/test/factories"
require "decidim/debates/test/factories"

FactoryBot.define do
  sequence(:word) do |n|
    "foobar#{n}"
  end

  factory :forbidden_word, class: "Decidim::Tools::Ai::ForbiddenKeyword" do
    word { generate(:word) }
  end

  factory :stopword, class: "Decidim::Tools::Ai::StopWord" do
    word { generate(:word) }
  end
end

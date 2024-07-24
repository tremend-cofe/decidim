# frozen_string_literal: true

module Decidim
  class BaseComponent < ViewComponent::Base
    delegate_missing_to :helpers
    strip_trailing_whitespace
  end
end

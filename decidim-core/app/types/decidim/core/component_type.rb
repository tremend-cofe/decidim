# frozen_string_literal: true

module Decidim
  module Core
    class ComponentType < Types::BaseObject
      implements ComponentInterface
      description "A base component with no particular specificities."
    end
  end
end

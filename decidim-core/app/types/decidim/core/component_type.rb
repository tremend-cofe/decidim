# frozen_string_literal: true

module Decidim
  module Core
    class ComponentType < Decidim::Api::Types::BaseObject
      implements ComponentInterface
      description "A base component with no particular specificities."
    end
  end
end

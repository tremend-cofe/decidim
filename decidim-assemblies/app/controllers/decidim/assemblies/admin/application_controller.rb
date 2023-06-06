# frozen_string_literal: true

module Decidim
  module Assemblies
    module Admin
      # The main admin application controller for assemblies
      class ApplicationController < Decidim::Admin::ApplicationController
        include Concerns::AssemblyAdmin
      end
    end
  end
end

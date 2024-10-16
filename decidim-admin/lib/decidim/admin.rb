# frozen_string_literal: true

require "decidim/admin/engine"

module Decidim
  # This module contains all the logic related to a admin-wide
  # administration panel. The scope of the domain is to be able
  # to manage Organizations (tenants), as well as have a bird's
  # eye view of the whole admin.
  #
  module Admin
    autoload :Components, "decidim/admin/components"
    autoload :FormBuilder, "decidim/admin/form_builder"
    autoload :SearchFormBuilder, "decidim/admin/search_form_builder"
    autoload :Import, "decidim/admin/import"
    autoload :CustomImport, "decidim/admin/custom_import"

    include ActiveSupport::Configurable

    # Public: Stores an instance of ViewHooks
    def self.view_hooks
      @view_hooks ||= ViewHooks.new
    end
  end
end

# frozen_string_literal: true

require "decidim/generators/version"

module Decidim
  module Generators
    def self.edge_git_branch
      if Decidim::Generators.version.match?(/\.dev$/)
        "upgrade/rails7"
      else
        "release/#{Decidim::Generators.version.match(/^[0-9]+\.[0-9]+/)[0]}-stable"
      end
    end
  end
end

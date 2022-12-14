# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/tools/ai/version"

Gem::Specification.new do |s|
  s.version = Decidim::Tools::Ai.version
  s.authors = ["Alexandru-Emil Lupu"]
  s.email = ["contact@alecslupu.ro"]
  s.license = "AGPL-3.0"
  s.homepage = "https://decidim.org"
  s.metadata = {
    "bug_tracker_uri" => "https://github.com/decidim/decidim/issues",
    "documentation_uri" => "https://docs.decidim.org/",
    "funding_uri" => "https://opencollective.com/decidim",
    "homepage_uri" => "https://decidim.org",
    "source_code_uri" => "https://github.com/decidim/decidim"
  }
  s.required_ruby_version = ">= 3.0"

  s.name = "decidim-tools-ai"
  s.summary = "A Decidim module with AI tools"
  s.description = "."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::Tools::Ai.version
  s.add_dependency "classifier-reborn"
  s.add_dependency "cld"
  s.add_development_dependency "decidim-dev", Decidim::Tools::Ai.version
end

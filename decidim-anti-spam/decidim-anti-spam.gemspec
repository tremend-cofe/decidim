# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/anti-spam/version"

Gem::Specification.new do |s|
  s.version = Decidim::AntiSpam.version
  s.authors = ["Cristian Georgescu"]
  s.email = ["georgescu.cristi@gmail.com"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/decidim/decidim-module-anti-spam"
  s.required_ruby_version = ">= 2.5"

  s.name = "decidim-anti-spam"
  s.summary = "A decidim anti-spam module"
  s.description = "AntiSpam Solution."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", Decidim::AntiSpam.version
end

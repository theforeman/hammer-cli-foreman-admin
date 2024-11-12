$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_foreman_admin/version"

Gem::Specification.new do |s|

  s.name = "hammer_cli_foreman_admin"
  s.authors = ["Lukas Zapletal"]
  s.email = "lzap+git@redhat.com"
  s.licenses = ["GPL-3.0-only"]
  s.homepage = "https://github.com/theforeman/hammer-cli-foreman-admin"
  s.version = HammerCLIForemanAdmin.version.dup
  s.platform = Gem::Platform::RUBY
  s.summary = %q{Foreman administrative commands plugin}
  s.description = %q{Foreman administrative commands plugin for Hammer CLI}

  s.files = Dir["{config,lib}/**/*"] + Dir["locale/**/*.{po,pot,mo}"]
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli', '~> 3.10', '< 4.0'

  s.required_ruby_version = '>= 2.7', '< 4'
end

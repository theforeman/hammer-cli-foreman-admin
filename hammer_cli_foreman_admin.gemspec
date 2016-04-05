$:.unshift File.expand_path("../lib", __FILE__)
require "hammer_cli_foreman_admin/version"

Gem::Specification.new do |s|

  s.name = "hammer_cli_foreman_admin"
  s.authors = ["Lukas Zapletal"]
  s.version = HammerCLIForemanAdmin.version.dup
  s.platform = Gem::Platform::RUBY
  s.summary = %q{Foreman administrative commands plugin}

  s.files = Dir['lib/**/*.rb']
  s.require_paths = ["lib"]

  s.add_dependency 'hammer_cli'
end

require 'bundler/gem_tasks'

namespace :pkg do
  desc 'Generate package source gem'
  task :generate_source => :build
end

require "hammer_cli_foreman_admin/version"
require "hammer_cli_foreman_admin/i18n"
require "hammer_cli/i18n/find_task"
HammerCLI::I18n::FindTask.define(HammerCLIForemanAdmin::I18n::LocaleDomain.new, HammerCLIForemanAdmin.version.to_s)

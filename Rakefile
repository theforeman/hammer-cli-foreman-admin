require 'bundler/gem_tasks'

namespace :gettext do
  task :setup do
    require "hammer_cli_foreman_admin/version"
    require "hammer_cli_foreman_admin/i18n"
    require 'gettext/tools/task'

    domain = HammerCLIForemanAdmin::I18n::LocaleDomain.new
    GetText::Tools::Task.define do |task|
      task.package_name = domain.domain_name
      task.package_version = HammerCLIForemanAdmin.version.to_s
      task.domain = domain.domain_name
      task.mo_base_directory = domain.locale_dir
      task.po_base_directory = domain.locale_dir
      task.files = domain.translated_files
    end
  end

  desc "Update pot file"
  task :find => [:setup] do
    Rake::Task["gettext:po:update"].invoke
  end
end

namespace :pkg do
  desc 'Generate package source gem'
  task :generate_source => :build
end

require 'hammer_cli'

module HammerCLIForemanAdmin
  class AdminCommand < HammerCLI::AbstractCommand; end

  HammerCLI::MainCommand.subcommand 'admin', _("Administrative server-side tasks"), HammerCLIForemanAdmin::AdminCommand
end

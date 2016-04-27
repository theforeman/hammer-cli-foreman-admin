require 'hammer_cli'

module HammerCLIForemanAdmin
  class LoggingCommand < HammerCLI::AbstractCommand

    option ["-d", "--level-debug"], :flag, _("Increase verbosity level to debug.")
    option ["-p", "--level-production"], :flag, _("Decrease verbosity level to standard.")
    option ["-c", "--components"], "COMPONENTS", _("Components to apply, use --list to get them."), :format => HammerCLI::Options::Normalizers::List.new
    option ["-l", "--list"], :flag, _("List available components.")
    option ["-a", "--all"], :flag, _("Apply to all components.")
    option ["-n", "--dry-run"], :flag, _("Do not apply specified changes.")
    option "--no-backup", :flag, _("Skip configuration backups creation.")
    option "--prefix", "PATH", _("Operate on prefixed environment (e.g. chroot).")

    validate_options do
      any(:option_level_debug, :option_level_production, :option_list).required
      any(:option_components, :option_all, :option_list).required
      all(:option_level_debug, :option_level_production).rejected
      any(:option_level_debug, :option_level_production).rejected if option(:option_list).exist?
    end

    def run_command(cmd, raise_on_error = true, verbose = false)
      output = `#{cmd}`
      print_message output if verbose && output.chomp != ''
      raise("return value = #{$?.to_i}") if $?.to_i != 0 && raise_on_error
    rescue Exception => e
      if raise_on_error
        raise "Command '#{cmd}' failed: #{e}"
      else
        print_message _("Command '%{cmd}' failed: %{e}") % {:cmd => cmd, :e => e}
      end
    end

    def check_options(hash, action_name, *required_keys)
      required_keys.each do |key|
        raise("Missing option '#{key}' in action '#{action_name}' component '#{hash[:name]}'") unless hash[key]
      end
    end

    def action_functions
      @action_functions ||= {
        :run_command => lambda do |opts|
          check_options opts, :run_command, :command
          run_command opts[:command], false
        end,
        :run_command_on_file => lambda do |opts|
          check_options opts, :run_command_on_file, :command, :file
          run_command "#{opts[:command]} #{opts[:file]}", false
        end,
        :create_file => lambda do |opts|
          check_options opts, :create_file, :file, :contents
          FileUtils.mkdir_p(File.dirname(opts[:file]))
          open(opts[:file], 'w') { |f| f.puts opts[:contents] }
        end,
        :remove_file => lambda do |opts|
          check_options opts, :remove_file, :file
          File.unlink(opts[:file]) if File.exist?(opts[:file])
        end,
        :ensure_line_is_present => lambda do |opts|
          check_options opts, :ensure_line_is_present, :file, :line
          if File.foreach(opts[:file]).grep(/#{opts[:line][0]}/).empty?
            open(opts[:file], 'a') { |f| f.puts "\n" + opts[:line].join }
          else
            run_command %Q|sed -i 's!#*#{opts[:line][0]}\s*#{opts[:line][1]}.*!#{opts[:line].join}!' #{opts[:file]}|
          end
        end
      }
    end

    def new_level
      option_level_debug? ? :debug : :production
    end

    def configure_component(component, level)
      name = component[:name]
      friendly_name = component[:friendly_name]
      file = component[:file]
      file = option_prefix + file if option_prefix
      backup_suffix = Time.now.utc.to_i.to_s(36)
      if File.exists?(file)
        component[level].each do |action|
          action_name = action[:action]
          action[:name] = name
          if action[:file]
            action[:file] = option_prefix + action[:file] if option_prefix
          else
            action[:file] = file
          end
          func = action_functions[action_name.to_sym]
          if func
            logger.info "Processing #{name} action #{action_name}"
            unless option_dry_run?
              unless option_no_backup?
                backup_file = "#{file}.#{backup_suffix}~"
                logger.info "Creating backup #{backup_file}"
                FileUtils.cp(file, backup_file)
              end
              func.call(action)
            end
          else
            raise "Unknown action #{action_name} for component #{name}"
          end
        end
      else
        logger.info "Skipped component #{name}, file #{file} does not exist"
      end
    end

    def available_components
      HammerCLI::Settings.get(:admin)[:logging][:component]
    end

    def execute
      # FIXME Workaround until https://github.com/theforeman/hammer-cli/pull/192/files
      HammerCLI::Settings.load_from_paths([File.expand_path('../../../config', __FILE__)]) unless HammerCLI::Settings.get(:admin)

      configuration = HammerCLI::Settings.get(:admin)[:logging][:component] rescue raise("Missing logging YAML definitions (foreman_admin_logging_*.yml)")
      if option_list?
        output_definition = HammerCLI::Output::Definition.new
        output_definition.fields << Fields::Field.new(:label => _('Component name'), :path => ["name"])
        output_definition.fields << Fields::Field.new(:label => _('Auto-detected by existence of'), :path => ["file"])
        output = HammerCLI::Output::Output.new(context, :default_adapter => :table)
        output.print_collection(output_definition, HammerCLI::Settings.get(:admin)[:logging][:component])
      else
        if option_all?
          components = configuration
        else
          raise("Unknown component provided, use --list to find them") unless option_components.all? { |c| available_components.include? c }
          components = configuration.select{ |x| option_components.include? x[:name] }
        end
        components.each { |component| configure_component(component, new_level) }
      end
      HammerCLI::EX_OK
    end
  end

  HammerCLIForemanAdmin::AdminCommand.subcommand 'logging', _("Logging verbosity level setup"), HammerCLIForemanAdmin::LoggingCommand
end

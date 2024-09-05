require 'hammer_cli'

module HammerCLIForemanAdmin
  class RemoveCommand < HammerCLI::AbstractCommand

    def execute
      if confirm
        `katello-service stop`

        print_message "Removing RPMs"
        RPMS.each do | rpm |
          packages =  `rpm -qa | grep "#{rpm}"`
          packages.lines.each { | package | `yum erase -y "#{ package.strip }" > /dev/null 2>&1` }
        end

        print_message "Cleaning up configuration files"
        FileUtils.rm_rf CONFIG_FILES

        print_message "Cleaning up log files"
        # logs
        FileUtils.rm_rf LOG_FILES

        print_message "Cleaning up Certs"
        # pulp cert stuff
        FileUtils.rm_rf CERT_FILES

        print_message "Cleaning up content"
        #content
        FileUtils.rm_rf CONTENT
      end

      HammerCLI::EX_OK
    end

    def confirm
      print_message "\nWARNING: This script will erase many packages and config files."
      print_message "Important packages such as the following will be removed:\n"
      print_message "  * httpd (apache)"
      print_message "  * mongodb"
      print_message "  * tomcat"
      print_message "  * puppet"
      print_message "  * ruby"
      print_message "  * rubygems"
      print_message "  * All Foreman and Plugin Packages\n"
      print_message "Once these packages and configuration files are removed there is no going back."
      print_message "If you use this system for anything other than Foreman you probably"
      print_message "do not want to execute this script.\n"

      print "Read the source for a list of what is removed.  Are you sure(Y/N)? "

      response = $stdin.gets.chomp
      if /[Y]/i.match(response)
        confirmed? ? true : cancel
      else
        cancel
      end
    end

    def cancel
      print_message "**** cancelled ****"
      false
    end

    def confirmed?
      print_message "\nARE YOU SURE?: This script permanently deletes data and configuration."
      print_message "Read the source for a list of what is removed.  Type [remove] to continue? "
      'remove' == ($stdin.gets.chomp)
    end

    CONFIG_FILES = [
      '/etc/pulp',
      '/etc/candlepin',
      '/etc/katello',
      '/etc/httpd',
      '/etc/tomcat6',
      '/etc/foreman',
      '/etc/tomcat',
      '/etc/foreman-installer',
      '/etc/foreman-proxy',
      '/etc/pki/katello-certs-tools',
      '/etc/sudoers.d/foreman-proxy',
      '/etc/hammer',
      '/etc/tomcat',
      '/etc/squid',
      '/etc/puppet',
      '/etc/puppetlabs',
      '/etc/qpid',
      '/etc/qpid-dispatch',
      '/etc/sysconfig/foreman.rpmsave'
    ]

    LOG_FILES = [
      '/var/log/katello',
      '/var/log/tomcat6',
      '/var/log/pulp',
      '/var/log/candlepin',
      '/var/log/httpd',
      '/var/log/mongodb',
      '/var/log/foreman',
      '/var/log/foreman-proxy',
      '/var/log/foreman-installer',
      '/var/log/tomcat',
      '/var/log/squid',
      '/var/log/capsule-certs-generate*'
    ]

    RPMS = [
      'puppetlabs-release',
      'foreman-release',
      'foreman-client',
      'foreman-proxy',
      'candlepin',
      'katello',
      '^pulp',
      '^python-pulp',
      '^pulp-',
      'mongo',
      'postgre',
      '^mod_',
      '^rubygem',
      '^ruby193',
      '^tfm',
      '^foreman',
      '^qpid',
      '^python-crane',
      '^python-celery',
      '^python-gofer',
      '^python-qpid',
      '^python-kombu',
      '^python-webpy',
      '^python-nectar',
      '^python-saslwrapper',
      '^python-amqp',
      '^python-billiard',
      '^python-semantic_version',
      '^python-requests',
      '^python-isodate',
      '$HOSTNAME',
      'saslwrapper',
      'ruby',
      'rubygems',
      'httpd',
      'puppet',
      'tomcat',
      'squid'
    ]

    CERT_FILES = [
      '/etc/pki/pulp',
      '/etc/pki/content/*',
      '/etc/pki/katello',
      '/root/ssl-build',
      '/etc/pki/tls/certs/katello-node.crt',
      '/etc/pki/tls/private/katello-node.key',
      '/etc/pki/tls/certs/pulp_consumers_ca.crt',
      '/etc/pki/tls/certs/pulp_ssl_cert.crt',
      '/var/www/html/pub/katello-ca*.rpm',
      '/etc/pki/ca-trust/source/anchors/katello_server-host-cert.crt'
    ]

    CONTENT = [
      '/var/cache/pulp',
      '/usr/share/foreman-proxy',
      '/usr/share/foreman-installer-katello',
      '/var/www/html/pub/katello-server-ca.crt',
      '/usr/share/foreman',
      '/var/lib/candlepin',
      '/usr/share/katello',
      '/var/lib/puppet',
      '/var/lib/pgsql',
      '/var/lib/mongodb',
      '/var/lib/katello',
      '/var/lib/pulp/',
      '/var/lib/foreman',
      '/usr/share/pulp',
      '/var/lib/tomcat',
      '/var/lib/qpidd',
      '/usr/share/candlepin',
      '/usr/share/tomcat',
      '/usr/share/katello-installer-base',
      '/usr/share/qpid',
      '/usr/share/qpid-tools',
      '/var/cache/candlepin',
      '/var/cache/foreman-proxy',
      '/var/cache/',
      '/opt/theforeman',
      '/var/www/html/pub/katello-rhsm-consumer'
    ]

  end
end

HammerCLIForemanAdmin::AdminCommand.subcommand 'remove', _("Removes Foreman and associated software from the system"), HammerCLIForemanAdmin::RemoveCommand

# Hammer CLI Foreman Admin

Plugin for Hammer CLI for administrative tasks on the Foreman and Smart Proxy
servers. Available sub-commands:

## logging

Sets debug or normal (production) configuration options for all Foreman
components. To set debug level for all components:

		# hammer admin logging --all --level-debug

To set production configuration:

		# hammer admin logging --all --level-production

Available options:

		# hammer admin logging --help
		Usage:
			hammer admin logging [OPTIONS]

		Options:
		 --no-backup                   Skip configuration backups creation.
		 --prefix PATH                 Operate on prefixed environment (e.g. chroot).
		 -a, --all                     Apply to all components.
		 -c, --components COMPONENTS   Components to apply, use --list to get them.
		 -d, --level-debug             Increase verbosity level to debug.
		 -h, --help                    print help
		 -l, --list                    List available components.
		 -n, --dry-run                 Do not apply specified changes.
		 -p, --level-production        Decrease verbosity level to standard.

Currently recognized components (files):

		# hammer admin logging --list
		-----------|-------------------------------------|-------------------------------------
		COMPONENT  | AUTO-DETECTED BY EXISTENCE OF       | DESTINATIONS
		-----------|-------------------------------------|-------------------------------------
		postgresql | /var/lib/pgsql/data/postgresql.conf | syslog /var/lib/pgsql/data/pg_log
		rails      | /etc/foreman/settings.yaml          | /var/log/foreman/production.log
		proxy      | /etc/foreman-proxy/settings.yml     | /var/log/foreman-proxy/proxy.log
		puppet     | /etc/puppet/puppet.conf             | /var/log/puppet/masterhttp.log
		dhcpd      | /etc/dhcp/dhcpd.conf                | syslog /var/log/dhcpd-debug.log
		named      | /etc/named.conf                     | syslog
		tftp       | /etc/xinetd.d/tftp                  | syslog
		qpidd      | /etc/qpid/qpidd.conf                | syslog
		tomcat     | /etc/candlepin/candlepin.conf       | /var/log/candlepin/ /var/log/tomcat/
		pulp       | /etc/pulp/server.conf               | syslog /var/log/pulp-debug.log
		virt-who   | /etc/sysconfig/virt-who             | syslog
		-----------|-------------------------------------|-------------------------------------

The tool uses search and replace approach declared in YAML configuration files
`foreman_admin_logging_core.yml` and `foreman_admin_logging_katello.yml`.

### Development

To test the logging subcommand, use the fixture examples and compare with git
diff:

    hammer -d admin logging --prefix $(pwd)/test/fixture_tree/ --no-backup -a -d

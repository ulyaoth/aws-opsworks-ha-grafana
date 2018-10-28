name 'ulyaoth_grafana'
maintainer 'Sjir Bagmeijer'
maintainer_email 'sjir.bagmeijer@ulyaoth.com'
description 'Installs and configures grafana on aws opsworks'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

recipe 'ulyaoth_grafana', 'defaults'
recipe 'ulyaoth_grafana::grafana-setup', 'Install Grafana'

supports 'amazon'

source_url 'https://github.com/ulyaoth/aws-opsworks-ha-grafana'
issues_url 'https://github.com/ulyaoth/aws-opsworks-ha-grafana/issues'

chef_version '>= 12'
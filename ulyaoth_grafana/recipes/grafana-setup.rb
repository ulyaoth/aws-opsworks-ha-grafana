instance_info = search(:aws_opsworks_instance, "self:true").first
stack_info = search("aws_opsworks_stack").first

### set the grafana service, so it can be started.
service 'grafana-server' do
  supports :status => true, :restart => true, :reload => true, :start => true, :enable => true
  action :nothing
end

### Start - Install Ulyaoth Repository.
remote_file "#{Chef::Config[:file_cache_path]}/ulyaoth-latest.amazonlinux.x86_64.rpm" do
    source "https://downloads.ulyaoth.com/rpm/ulyaoth-latest.amazonlinux.x86_64.rpm"
    action :create
end

rpm_package "ulyaoth" do
    source "#{Chef::Config[:file_cache_path]}/ulyaoth-latest.amazonlinux.x86_64.rpm"
    action :install
    ignore_failure true
end
### End - Install Ulyaoth Repository.

### Install some additional packages with yum.
yum_package ['mlocate', 'git', 'htop', 'wget'] do
  action :install
end

### Start - Install Grafana rpm.
remote_file "#{Chef::Config[:file_cache_path]}/grafana-5.3.2-1.x86_64.rpm" do
    source "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana-5.3.2-1.x86_64.rpm"
    action :create
	notifies :run, 'execute[rpm-import-gpg-grafana]', :immediately
end

execute 'rpm-import-gpg-grafana' do
  command 'rpm --import https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana'
  action :nothing
  notifies :install, 'rpm_package[grafana]', :immediately
end

rpm_package "grafana" do
    source "#{Chef::Config[:file_cache_path]}/grafana-5.3.2-1.x86_64.rpm"
    action :nothing
    ignore_failure true
	notifies :enable, 'service[grafana-server]', :delayed
end
### End - Install Grafana rpm.
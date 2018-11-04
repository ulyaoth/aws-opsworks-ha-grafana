instance_info = search(:aws_opsworks_instance, "self:true").first
stack_info = search("aws_opsworks_stack").first

$mysql_host_var = node[:ulyaoth_tutorial][:mysql_host]
$mysql_user_var = node[:ulyaoth_tutorial][:mysql_user]
$mysql_password_var = node[:ulyaoth_tutorial][:mysql_password]
$memcache_host_var = node[:ulyaoth_tutorial][:memcache_host]

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
yum_package ['mlocate', 'git', 'htop', 'wget', 'urw-fonts'] do
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
	notifies :create, 'template[/etc/grafana/grafana.ini]', :immediately
end
### End - Install Grafana rpm.

### Create the grafana config file.
template '/etc/grafana/grafana.ini' do
  source "grafana.ini.erb"
  owner 'root'
  group 'grafana'
  mode '0640'
  action :nothing
  variables({
    :mysql_host => "#{$mysql_host_var}",
    :mysql_user => "#{$mysql_user_var}",
    :mysql_password => "#{$mysql_password_var}",
    :memcache_host => "#{$memcache_host_var}"
  })
  notifies :enable, 'service[grafana-server]', :immediately
  notifies :start, 'service[grafana-server]', :delayed
end

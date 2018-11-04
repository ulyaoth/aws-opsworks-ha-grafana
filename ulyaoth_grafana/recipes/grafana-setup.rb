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

### Install grafana with yum.
yum_package 'grafana' do
  action :nothing
  flush_cache [ :before ]
  notifies :enable, 'service[grafana-server]', :delayed
end

### Create yum repository file for grafana.
template '/etc/yum.repos.d/grafana.repo' do
  source "grafana.repo.erb"
  owner 'root'
  group 'root'
  mode '0755'
  notifies :install, 'yum_package[grafana]', :immediate
end


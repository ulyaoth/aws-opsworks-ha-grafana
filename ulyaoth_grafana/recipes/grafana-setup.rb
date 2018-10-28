instance_info = search(:aws_opsworks_instance, "self:true").first
stack_info = search("aws_opsworks_stack").first

### Start - Install basic packages.
remote_file "#{Chef::Config[:file_cache_path]}/ulyaoth-latest.amazonlinux.x86_64.rpm" do
    source "https://downloads.ulyaoth.net/rpm/ulyaoth-latest.amazonlinux.x86_64.rpm"
    action :create
end

rpm_package "ulyaoth" do
    source "#{Chef::Config[:file_cache_path]}/ulyaoth-latest.amazonlinux.x86_64.rpm"
    action :install
    ignore_failure true
end

service 'grafana' do
  supports :status => true, :restart => true, :reload => true, :start => true, :enable => true
  action :nothing
end

template '/etc/yum.repos.d/grafana.repo' do
  source "grafana.repo.erb"
  owner 'root'
  group 'root'
  mode '0755'
  notifies :install, 'yum_package[grafana]', :immediate
end

yum_package ['mlocate', 'git', 'htop', 'wget', 'grafana'] do
  action :nothing
  notifies :enable, 'service[grafana]', :delayed
end
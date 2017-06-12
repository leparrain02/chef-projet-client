#
# Cookbook:: mg_web
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# disable selinux because it blocks mod_jk execution
execute 'disable_selinux' do
  command 'setenforce 0'
  action :nothing
end

template '/etc/sysconfig/selinux' do
  source 'selinux.erb'
  notifies :run, 'execute[disable_selinux]', :immediate
end

firewall 'default' do
  action :install
end

firewall_rule 'ssh' do
  port 22
  command :allow
end

include_recipe 'mg_web::web'

firewall_rule 'http' do
  port 80
  command :allow
end

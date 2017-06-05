#
# Cookbook:: tomcat
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

tomcat_version='8.0.44'

package 'java-1.7.0-openjdk-devel' do
end

group node['tomcat']['group']

user node['tomcat']['username'] do
  group node['tomcat']['group']
  shell '/bin/nologin'
  home '/opt/tomcat'
  manage_home false
end

directory '/opt/tomcat' do
end

tar_extract "http://apache.mirror.colo-serv.net/tomcat/tomcat-8/v#{tomcat_version}/bin/apache-tomcat-#{tomcat_version}.tar.gz" do
  target_dir '/opt/tomcat'
  creates "/opt/tomcat/apache-tomcat-#{tomcat_version}/lib"
end

template "/opt/tomcat/apache-tomcat-#{tomcat_version}/conf/server.xml" do
  source 'server.xml.erb'
end

fileutils 'conf' do
  path "/opt/tomcat/apache-tomcat-#{tomcat_version}"
  group node['tomcat']['group']
  file_mode 'g+r'
  directory_mode 'g+rwx'
  recursive true
  not_if "stat -c '%G' conf|grep '^ *tomcat *$'"
end

cookbook_file "/opt/tomcat/apache-tomcat-#{tomcat_version}/lib/mysql-connector-java-5.0.8-bin.jar" do
  source 'mysql-connector-java-5.0.8-bin.jar'
  user 'tomcat'
  group 'tomcat'
  mode '0644'
end

%w( webapps work temp logs).each do |repertoire|
  fileutils "#{repertoire}" do
    path "/opt/tomcat/apache-tomcat-#{tomcat_version}"
    owner node['tomcat']['username']
    recursive true
    not_if "stat -c '%U' #{repertoire}|grep '^ *tomcat *$'"
  end
end

execute 'daemon-reload' do
  command 'systemctl daemon-reload'
  action :nothing
end 

template '/etc/systemd/system/tomcat.service' do
  source 'tomcat.service.erb'
  owner  'root'
  group  'root'
  mode   '0644'
  notifies :run, 'execute[daemon-reload]', :immediate
end

service 'tomcat' do
  action [:enable, :start]
end

#directory "/opt/tomcat/apache-tomcat-#{tomcat_version}/webapps/customer" do
#  owner 'tomcat'
#  group 'tomcat'
#  mode  '0755'
#end

#directory "/opt/tomcat/apache-tomcat-#{tomcat_version}/webapps/customer/lib" do
#  owner 'tomcat'
#  group 'tomcat'
#  mode  '0755'
#end

#directory "/opt/tomcat/apache-tomcat-#{tomcat_version}/webapps/customer/WEB-INF" do
#  owner 'tomcat'
#  group 'tomcat'
#  mode  '0755'
#end

#cookbook_file "/opt/tomcat/apache-tomcat-#{tomcat_version}/webapps/customer/lib/standard.jar" do
#  source 'standard.jar'
#  owner 'tomcat'
#  group 'tomcat'
#  mode '0644'
#end

#cookbook_file "/opt/tomcat/apache-tomcat-#{tomcat_version}/webapps/customer/lib/jstl.jar" do
#  source 'jstl.jar'
#  owner 'tomcat'
#  group 'tomcat'
#  mode '0644'
#end

cookbook_file "/opt/tomcat/apache-tomcat-#{tomcat_version}/webapps/customer.war" do
  source "customer.war"
  owner 'tomcat'
  group 'tomcat'
  mode '644'
end
